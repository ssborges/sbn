# = SBN: Simple Bayesian Networks
# Copyright (C) 2005-2007  Carl Youngblood mailto:carl@youngbloods.org
# 
# SBN makes it easy to use Bayesian Networks in your ruby application. Why would you
# want to do this? Bayesian networks are excellent tools for making intelligent
# decisions based on collected data. They are used to measure and predict the
# probabilities of various outcomes in a problem space.
# 
# A Bayesian Network is a directed acyclic graph representing the variables in a
# problem space, the causal relationships between these variables and the
# probabilities of these variables' possible states, as well as the algorithms used
# for inference on these variables.
# 
# == A Basic Example
# link://../images/grass_wetness.png
# 
# We'll begin with a network whose probabilities have been pre-determined. This
# example comes from the excellent <em>Artificial Intelligence: A Modern
# Approach</em>, by Russell & Norvig. Later we'll see how to determine a network's
# probabilities from training data. Our sample network has four variables, each of
# which has two possible states:
# * <em>Cloudy</em>: <b>:true</b> if sky is cloudy, <b>:false</b> if sky is sunny.
# * <em>Sprinkler</em>: <b>:true</b> if sprinkler was turned on, <b>:false</b> if not. Whether or not it's cloudy has a direct influence on whether or not the sprinkler is turned on, so there is a parent-child relationship between <em>Sprinkler</em> and <em>Cloudy</em>.
# * <em>Rain</em>: <b>:true</b> if it rained, <b>:false</b> if not. Whether or not it's cloudy has a direct influence on whether or not it will rain, so there is a relationship there too.
# * <em>Grass Wet</em>: <b>:true</b> if the grass is wet, <b>:false</b> if not. The state of the grass is directly influenced by both rain and the sprinkler, but cloudiness has no direct influence on the state of the grass, so grass has a relationship with both <em>Sprinkler</em> and <em>Rain</em> but not <em>Cloudy</em>.
# 
# Each variable holds a state table representing the conditional probabilties of each
# of its own states given each of its parents' states. <em>Cloudy</em> has no
# parents, so it only has probabilities for its own two states. <em>Sprinkler</em>
# and <em>Rain</em> each have one parent, so they must specify probabilities for all
# four possible combinations of their own states and their parents' states. Since
# <em>Grass Wet</em> has two parents, it must specify all eight possible combinations
# of states. Since we live in a logical universe, each variable's possible states
# given a specific combination of its parents' states must add up to 1.0. Notice that
# <em>Cloudy</em>'s probabilities add up to 1.0, <em>Sprinkler</em>'s states given
# <em>Cloudy</em> == :true add up to 1.0 and so on.
# 
#  require 'sbn'
# 
#  net       = Sbn::Net.new("Grass Wetness Belief Net")
#  cloudy    = Sbn::Variable.new(net, :cloudy, [0.5, 0.5])
#  sprinkler = Sbn::Variable.new(net, :sprinkler, [0.1, 0.9, 0.5, 0.5])
#  rain      = Sbn::Variable.new(net, :rain, [0.8, 0.2, 0.2, 0.8])
#  grass_wet = Sbn::Variable.new(net, :grass_wet, [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0])
#  cloudy.add_child(sprinkler)        # also creates parent relationship 
#  cloudy.add_child(rain)
#  sprinkler.add_child(grass_wet)
#  rain.add_child(grass_wet)
#  evidence = {:sprinkler => :false, :rain => :true}
#  net.set_evidence(evidence)
#  net.query_variable(:grass_wet)
# 
#  => {:true=>0.8995, :false=>0.1005} # inferred probabilities for grass_wet
#                                     # given sprinkler == :false and rain == :true
# 
# === Specifying probabilities
# 
# The order that probabilities are supplied is as follows. Always alternate between
# the states of the variable whose probabilties you are supplying. Supply the
# probabilities of these states given the variable's parents in the order the parents
# were added, from right to left, with the rightmost (most recently added) parent
# alternating first. For example, if I have one variable A with two parents B and C,
# A having three states, B having two, and C having four, I would supply the
# probabilities in the following order:
#  
#  P(A1|B1,C1)   # this notation means "The probability of A1 given B1 and C1"
#  P(A2|B1,C1)
#  P(A3|B1,C1)
#  
#  P(A1|B1,C2)
#  P(A2|B1,C2)
#  P(A3|B1,C2)
# 
#  P(A1|B1,C3)
#  P(A2|B1,C3)
#  P(A3|B1,C3)
# 
#  P(A1|B1,C4)
#  P(A2|B1,C4)
#  P(A3|B1,C4)
# 
#  P(A1|B2,C1)
#  P(A2|B2,C1)
#  P(A3|B2,C1)
# 
#  P(A1|B2,C2)
#  P(A2|B2,C2)
#  P(A3|B2,C2)
# 
#  P(A1|B2,C3)
#  P(A2|B2,C3)
#  P(A3|B2,C3)
# 
#  P(A1|B2,C4)
#  P(A2|B2,C4)
#  P(A3|B2,C4)
# 
# A more verbose, but possibly less confusing way of specifying probabilities is to
# set the specific probability for each state separately using a hash to represent
# the combination of states:
# 
#  net = Sbn::Net.new("Grass Wetness Belief Net")
#  cloudy    = Sbn::Variable.new(net, :cloudy)      # states default to :true and :false
#  sprinkler = Sbn::Variable.new(net, :sprinkler)
#  rain      = Sbn::Variable.new(net, :rain)
#  grass_wet = Sbn::Variable.new(net, :grass_wet)
#  cloudy.add_child(sprinkler)
#  cloudy.add_child(rain)
#  sprinkler.add_child(grass_wet)
#  rain.add_child(grass_wet)
#  cloudy.set_probability(0.5, {:cloudy => :true})
#  cloudy.set_probability(0.5, {:cloudy => :false})
#  sprinkler.set_probability(0.1, {:sprinkler => :true, :cloudy => :true})
#  sprinkler.set_probability(0.9, {:sprinkler => :false, :cloudy => :true})
#  sprinkler.set_probability(0.5, {:sprinkler => :true, :cloudy => :false})
#  sprinkler.set_probability(0.5, {:sprinkler => :false, :cloudy => :false})
#  # etc etc
# 
# === Inference
# 
# After your network is set up, you can set evidence for specific variables that you
# have observed and then query unknown variables to see the posterior probability of
# their various states. Given these inferred probabilties, one common decision-making
# strategy is to assume that the variables are set to their most probable states.
# 
#  evidence = {:sprinkler => :false, :rain => :true}
#  net.set_evidence(evidence)
#  net.query_variable(:grass_wet)
# 
#  => {:true=>0.8995, :false=>0.1005} # inferred probabilities for grass_wet
#                                     # given sprinkler == :false and rain == :true
# 
# The only currently supported inference algorithm is the Markov Chain Monte Carlo
# (MCMC) algorithm. This is an approximation algorithm. Given the complexity of
# inference in Bayesian networks (NP-hard[http://en.wikipedia.org/wiki/NP-hard]),
# exact inference is often infeasible. The MCMC algorithm approximates the posterior
# probability for each variable's state by generating a random set of states for the
# unset variables in proportion to each state's posterior probability. It generates
# successive random states conditioned on the previous values of the non-evidence
# variables. The reason this works is because over time, the amount of time spent in
# each random state is proportional to its posterior probabilty.
# 
# == Training a Network
# 
# Although it is sometimes useful to be able to specify a variable's probabilities
# in advance, we usually begin with a clean slate, and only are able to make a
# reasonable estimate of each variable's probabilities after collecting sufficient
# data. This estimation process is easy with SBN. The training process requires
# complete observations for all variables in the network. Each set of training data
# is a hash with keys matching each variable's name and values corresponding to
# each variable's observed state. The more training data you supply to your
# network, the more accurate its probability estimates will be.
#
#  net.train([
#    {:cloudy => :true, :sprinkler => :false, :rain => :true, :grass_wet => :true},
#    {:cloudy => :true, :sprinkler => :true, :rain => :false, :grass_wet => :true},
#    {:cloudy => :false, :sprinkler => :false, :rain => :true, :grass_wet => :true},
#    {:cloudy => :true, :sprinkler => :false, :rain => :true, :grass_wet => :true},
#    {:cloudy => :false, :sprinkler => :true, :rain => :false, :grass_wet => :false},
#    {:cloudy => :false, :sprinkler => :false, :rain => :false, :grass_wet => :false},
#    {:cloudy => :false, :sprinkler => :false, :rain => :false, :grass_wet => :false},
#    {:cloudy => :true, :sprinkler => :false, :rain => :true, :grass_wet => :true},
#    {:cloudy => :true, :sprinkler => :false, :rain => :false, :grass_wet => :false},
#    {:cloudy => :false, :sprinkler => :false, :rain => :false, :grass_wet => :false},
#  ])
#
# Networks store the training data you have given them, so that future training
# continues to take previous data into account. The training process is
# straightforward. The frequency of each state combination in each variable is
# determined, and the number of occurrences for each state combination are divided
# by the total number of combinations trained on.
# 
# == Saving and Restoring a Network
#
# SBN currently supports the {XMLBIF
# format}[http://www.cs.cmu.edu/afs/cs/user/fgcozman/www/Research/InterchangeFormat]
# for serializing Bayesian networks:
#  
#  FILENAME = 'grass_wetness.xml'
#  File.open(FILENAME, 'w') do |f|
#    f.write(net.to_xmlbif)
#  end
#  reconstituted_net = net.from_xmlbif(File.read(FILENAME))
#
# At present, training data is not saved with your network, but this feature is
# anticipated in a future release.
#
# == Advanced Variable Types
# Among SBN's most powerful features are its advanced variable types, which make it
# much more convenient to handle real-world data, and increase the accuracy of your
# inference.
#
# === Sbn::StringVariable
# Sbn::StringVariable is used for handling string data.  Rather than setting this
# type of variable's states manually, rely on the training
# process.  During training, you should pass the observed string for this variable
# for each training set.  Each observed string is divided into a series of n-grams
# (short character sequences) matching snippets of the observed string.  A new
# variable is created (of class Sbn::StringCovariable) for each ngram, whose state
# will be :true or :false depending on whether the snippet is observed or not.
# These covariables are managed by the main StringVariable to which they belong
# and are transparent to you, the developer.  They inherit the same parents and
# children as their managing StringVariable.  By dividing observed string data
# into fine-grained substrings and determining separate probabilities for each substring
# occurrence, an extremely accurate picture of the data can be developed.
#
# === Sbn::NumericVariable
# Sbn::NumericVariable is used for handling numeric data, which is continuous
# and is thus more difficult to categorize than discrete states.  Due to the nature
# of the MCMC algorithm used for inference, every variable in the network must
# have discrete states, but this limitation can be ameliorated by dynamically
# altering a numeric variable's states according to the variance of
# the numeric data.  Whenever training occurs, the average and standard deviation
# of the observations for the NumericVariable are calculated, and the occurrences
# are divided into multiple categories through a process known as discretization.
# For example, all numbers between 1.0 and 3.5 might be classified as one state,
# and all numbers between 3.5 and 6 might be classified in another.  The thresholds
# for each state are based on the mean and standard deviation of the observed
# data, and are recalculated every time training occurs, so even though some amount
# of accuracy is lost by discretization, the states chosen are well-adapted to the
# data in your domain.  This variable type makes it much easier to work with numeric
# data by dynamically adapting to your data and handling the discretization for you.
#
# == Potential Improvements
#

class Sbn
  class Net
    attr_reader :name, :variables
    
    def initialize(name = '')
      @@net_count ||= 0
      @@net_count += 1
      @name = (name.empty? ? "net_#{@@net_count}" : name.to_underscore_sym)
      @variables = {}
      @evidence = {}
    end

    def ==(obj); test_equal(obj); end
    def eql?(obj); test_equal(obj); end
    def ===(obj); test_equal(obj); end
  
    def add_variable(variable)
      name = variable.name
      if @variables.has_key? name
        raise "Variable of same name has already been added to this net"
      end
      @variables[name] = variable
    end
    
    def symbolize_evidence(evidence) # :nodoc:
      newevidence = {}
      evidence.each do |key, val|
        key = key.to_underscore_sym
        newevidence[key] = @variables[key].transform_evidence_value(val)
      end
      newevidence
    end
    
    def set_evidence(event)
      @evidence = symbolize_evidence(event)
    end

  private
    def test_equal(net)
      returnval = true
      returnval = false unless net.class == self.class and self.class == Net
      returnval = false unless net.name == @name
      returnval = false unless @variables.keys.map {|k| k.to_s}.sort == net.variables.keys.map {|k| k.to_s}.sort
      net.variables.each {|name, variable| returnval = false unless variable == @variables[name] }
      returnval
    end
  end
end

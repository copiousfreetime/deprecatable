require 'forwardable'

module Deprecatable
  # This holds pointers to all the instances of DeprecatedMethod
  class Registry

    extend Forwardable
    def_delegators :@registry, :size, :each, :clear

    def initialize
      @registry = Hash.new
    end

    # Register a method to be deprecated.
    #
    # method - then instance of DeprecatedMethod
    #
    def register( dm )
      @registry[dm] = true
      return dm
    end

    # return all the DeprecatedMethod instances in the registry
    def items
      @registry.keys
    end
  end
end

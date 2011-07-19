require 'deprecatable/deprecated_method'
require 'forwardable'

module Deprecatable
  # This is a registry of deprecated methods. It is really nothing more than a
  # wrapper around a hash
  class Registry

    extend Forwardable
    def_delegators :@registry, :size, :each, :clear

    def initialize
      @registry = Hash.new
    end

    # Register a method to be deprecated.
    # 
    # method - The method to deprecate.
    # file   - The file in which the deprecated method is defined.
    # line   - The line number in the file on which the method is defined.
    #
    # Returns the DeprecatedMethod instance created.
    def deprecated_method( klass, method, file, line )
      dm = DeprecatedMethod.new( klass, method, file, line )
      @registry[dm] = true
      return dm
    end

    def items
      @registry.keys
    end
  end
end

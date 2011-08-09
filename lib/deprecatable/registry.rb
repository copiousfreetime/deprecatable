module Deprecatable
  # The Registry is a container of unique DeprecatedMethod instances.
  # Normally there is only one in existence and it is accessed via
  # 'Deprecatable.registry'
  class Registry
    # Initialize the Registry, which amounts to creating a new Hash.
    #
    # Returns nothing.
    def initialize
      @registry = Hash.new
    end

    # Public: Return the number of instances of DeprecatedMethod there are in
    # the Registry.
    #
    # Returns an Integer of the size of the Regsitry.
    def size()
      @registry.size
    end

    # Public: Iterate over all items in the Registry
    #
    # Yields each DeprecatedMethod in the Registry
    # Returns nothing.
    def each
      items.each do |i|
        yield i
      end
    end

    # Public: Remove all items from the Registry.
    #
    # Returns nothing.
    def clear
      @registry.clear
    end

    # Public: Register a method to be deprecated.
    #
    # method - An instance of DeprecatedMethod
    #
    # Returns the instance that was passed in.
    def register( dm )
      @registry[dm] = true
      return dm
    end

    # Public: Return all the DeprecatedMethod instances in the registry.
    #
    # Returns an Array of DeprecatedMethod instances.
    def items
      @registry.keys
    end
  end
end

# Allow methods to be deprecated and record when they are called. Each method
# that is marked via the deprecated class method is wrapped, and calls to the 
# deprecated method are recorded.
#
# There are configurable options for the extended class:
#
# For example:
#
#   class Foo
#     extend Deprecatable
#
#     def bar
#       ...
#     end
#
#     deprecate :bar, "foo"
#
#   end
#
require 'deprecatable/options'
require 'deprecatable/registry'
module Deprecatable
  VERSION = '1.0.0'

  # Deprecate a method in the included class.
  #
  # method_name - The method in this class to deprecate.
  # message     - A contextual message to output when the deprecated method is
  #               invoked.
  # year        - The year in which the deprecated method will be removed from
  #               the system.
  # month       - The month in which the deprecated method will be removed from
  #               the system.
  #
  # returns the instance of DeprecatedMethod created to track this deprecation.
  def deprecate( method_name, message = nil, year = nil, month = nil )
    file, line = Util.location_of_caller
    dm         = Deprecatable.registry.deprecated_method( self, method_name, file, line )

    if not method_defined?( dm.deprecated_method_name ) then
      alias_method dm.deprecated_method_name, method_name

      define_method( method_name ) do |*args, &block|
        dm.mark( *Util.location_of_caller )
        send( dm.deprecated_method_name, *args, &block )
      end
    end
    return dm
  end

  # Access the global registry
  #
  # Returns the instance of the registry
  @registry = Deprecatable::Registry.new
  def self.registry
    @registry
  end

  # Access the global Options
  @options = Deprecatable::Options.new
  def self.options
    @options
  end
end

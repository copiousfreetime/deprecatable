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
  # options     - a hash of the current understood options:
  #
  #    :message   => override the default message that would be issued with this message
  #    :year      => The year in which the deprecated method will be removed
  #    :month     => The month in which the deprecated method will be removed
  #
  # returns the instance of DeprecatedMethod created to track this deprecation.
  def deprecate( method_name, options = {} )
    file, line = Util.location_of_caller
    dm         = DeprecatedMethod.new( self, method_name, file, line, options )

    Deprecatable.registry.register( dm )

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
require 'deprecatable/invocation_event'
require 'deprecatable/deprecated_method'

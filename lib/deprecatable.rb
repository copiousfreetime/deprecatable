require 'deprecatable/options'
require 'deprecatable/registry'
require 'deprecatable/alerter'

# Allow methods to be deprecated and record and alert when those 
# deprecated methods are called.
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
#     deprecate :bar, :message => "Foo#bar has been deprecated, use Foo#foo instead"
#
#   end
#
module Deprecatable

  VERSION = '1.0.0'

  # Public: Deprecate a method in the included class.
  #
  # method_name - The method in this class to deprecate.
  # options     - a hash of the current understood options (default: {})
  #               :message         - A String to output along with the rest of
  #                                  the notifcations about the deprecated
  #                                  method.
  #               :removal_date    - The date on which the deprecated method
  #                                  will be removed.
  #               :removal_version - The version on which the deprecated 
  #                                  method will be removed.
  #
  # returns the instance of DeprecatedMethod created to track this deprecation.
  def deprecate( method_name, options = {} )
    file, line = Util.location_of_caller
    dm         = DeprecatedMethod.new( self, method_name, file, line, options )

    Deprecatable.registry.register( dm )

   return dm
  end

  # The global Deprecatable::Registry instance. It is set here so it is
  # allocated at parse time.
  @registry = Deprecatable::Registry.new

  # Public: Get the global Deprecatable::Registry instance
  #
  # Returns the global Deprecatable::Registry instance.
  def self.registry
    @registry
  end

  # The global options for Deprecatable. It is set here so it is allocated at
  # parse time.
  @options = Deprecatable::Options.new

  # Public: Access the global Options
  #
  # Returns the global Deprecatable::Options instance.
  def self.options
    @options
  end

  # The global Alerter for Deprecatable. It is set here so it is allocated at
  # parse time.
  @alerter = Deprecatable::Alerter.new

  # Public: Access the global Alerter
  #
  # Returns the global Alerter instance
  def self.alerter
    @alerter
  end

  # Public: Set the global Alerter
  #
  # alerter - Generally an instance of Alerter, but may be anything that
  #           responds_to? both :alert and :report. See the Alerter 
  #           documetation for more information
  #
  # Returns nothing.
  def self.alerter=( a )
    @alerter = a
  end
end

require 'deprecatable/util'
require 'deprecatable/call_site_context'
require 'deprecatable/call_site'
require 'deprecatable/deprecated_method'

# The at_exit handler is set at all times, and it will always fire, unless the
# process is killed with prejudice and/or the ruby process exists using 'exit!'
# instead of the normal 'exit'
at_exit do
  if ::Deprecatable.options.has_at_exit_report? then
    ::Deprecatable.alerter.final_report
  end
end

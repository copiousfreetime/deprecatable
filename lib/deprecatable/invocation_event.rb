module Deprecatable
  # InvocationEvent is a conatiner for the data that surrounds the invocation of
  # a deprecated method
  class InvocationEvent

    # The instance of DeprecatedMethod that is associated with this even
    attr_reader :deprecated_method

    # The filename where the deprecated method was invoked
    attr_reader :caller_file

    # the line number in caller_file where the deprecated  method was invoked
    attr_reader :caller_line_number

    # Create a new InvocationEvent
    #
    # deprecated_method  - the DeprecatedMethod instances for this invocation
    # caller_file        - the full path to the file that invoked the deprecated
    #                      method
    # caller_line_number - the line number in caller_file where the invocation
    #                      happened
    #
    # returns a new instances of InvocationEvent
    def initialize( deprecated_method, caller_file, caller_line_number )
      @deprecated_method  = deprecated_method
      @caller_file        = caller_file
      @caller_line_number = caller_line_number
    end
  end
end

module Deprecatable
  # 
  # A Container for the options that make up deprecatable
  #
  # caller_context_padding - The number of lines of context surrounding the call
  #                          site of the deprecated method to display in the
  #                          reports
  # at_exit_report         - Should Deprecatable output a final report
  #
  class Options
    # return the number of lines surrounding the call site to display in the
    # deprecation reports. The default is 2.
    attr_reader :caller_context_padding

    # set the number of lines of padding surrounding the callsite of the
    # deprecated method to report
    #
    # count - The number of lines before and after the callsite to report.
    #         This must be a positive number.
    def caller_context_padding=( count )
      raise ArgumentError, "caller_content_padding must have a count >= 0" unless count > 0
      @caller_context_padding = count
    end

    # return whether or not Deprecatable should issue a final report of all the
    # locations a deprecated method was invoked.
    def at_exit_report?
      @at_exit_report
    end

    # set whether or not the exit report will be emitted.
    #
    # bool - true or false, shall the exit report be emitted?
    attr_writer :at_exit_report

    def initialize
      @caller_context_padding = 2
      @at_exit_report         = true
    end
  end
end

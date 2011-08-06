module Deprecatable
  #
  # A Container for the options that make up deprecatable
  #
  class Options
    # The number of lines of context surrounding the call site of the deprecated
    # method to display in the reports.
    attr_reader :caller_context_padding

    # Set the number of caller_context_padding lines
    #
    # count - The number of lines before and after the callsite to report.
    #         This must be a positive number.
    #
    def caller_context_padding=( count )
      raise ArgumentError, "caller_content_padding must have a count > 0" unless count > 0
      @caller_context_padding = count
    end

    # Should a final report be output at the end of the program.
    #
    # bool - true or false, shall the exit report be emitted?
    attr_writer :has_at_exit_report
    def has_at_exit_report?; @has_at_exit_report; end

    # How many times to send out the individual alerts.
    #
    # That is, when a deprecated method is called, this is the number of times
    # to alert the user vial the warning mechanism.
    #
    # If this is set to a negative number, then alerting will happen with ever
    # method call to the deprecated method.
    #
    # The default is 1
    attr_reader :maximum_alert_count

    def initialize
      @caller_context_padding = 2
      @has_at_exit_report     = true
      @maximum_alert_count    = 1
    end
  end
end

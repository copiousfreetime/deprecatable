module Deprecatable
  # A Container for the options of Deprecatable.
  #
  # The available options are:
  #
  #    caller_context_padding - The number of lines before and after the call
  #                             site of the deprecated method to record
  #    alert_frequency        - The maximum number of times to alert for a given
  #                             call to the deprecated method
  #    at_exit_report         - Whether or not a deprecation report is issued
  #                             when the program exits
  #
  # These options may also be overridden with environment varaibles
  #
  #   DEPRECATABLE_CALLER_CONTEXT_PADDING
  #   DEPRECATABLE_ALERT_FREQUENCY
  #   DEPRECATABLE_AT_EXIT_REPORT
  #
  class Options
    # Create a new instance of Options. All of the default values for the
    # options are set.
    #
    #   caller_context_padding - 2
    #   has_at_exit_report     - true
    #   alert_frequency        - 1
    def initialize
      reset
    end

    # set the options to their default values
    def reset
      @caller_context_padding = 2
      @has_at_exit_report     = true
      @alert_frequency        = 1
    end

    # The number of lines of context surrounding the call site of the deprecated
    # method to display in the reports.
    #
    # count - The number of lines before and after the callsite to report.
    #         This must be a positive number.
    #
    def caller_context_padding=( count )
      raise ArgumentError, "caller_content_padding must have a count > 0" unless count > 0
      @caller_context_padding = count
    end

    # Return the caller context padding.
    #
    # This may be overridden with the environment variable
    # DEPRECATABLE_CALLER_CONTEXT_PADDING
    def caller_context_padding
      p = ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING']
      return Float(p).to_i if p
      return @caller_context_padding
    end

    # The maximum number of times an alert will be emitted.
    #
    # That is, when a deprecated method is called, this is the number of times
    # to alert the user via the warning mechanism. This is record on a
    # per-call-site count. This means, that if the same deprecated method is
    # called from two different locations, it will alert up to this value for
    # each location.
    #
    # This may be set to any number. Or to one of the special tokens
    # :never, :once, :always, which are just user friendly references
    # for 0, 1 and Infinity respectively
    #
    # The default is :once
    #
    # returns the curent value
    def alert_frequency=( freq )
      @alert_frequency = frequency_of( freq )
    end

    # Return the current value of 'alert_frequency'. This will return the
    # Numeric value. If the alert_frequency was set with :never, :once or
    # :always, the value that is returned here is the Numeric representation of
    # that token.
    #
    # This may be overridden with the environment variable
    # DEPRECATABLE_ALERT_FREQUENCY
    def alert_frequency
      p = ENV['DEPRECATABLE_ALERT_FREQUENCY']
      return frequency_of(p) if p
      return @alert_frequency
    end

    # Set whether or not the final at_exit_report should be emitted
    #
    # bool - true or false, shall the exit report be emitted?
    attr_writer :has_at_exit_report

    # return the current vaelu of has_at_exit_report. This may be overridden
    # with the environment variable DEPRECATABLE_HAS_AT_EXIT_REPORT. Setting the
    # environment variable to 'true' will override the existing setting.
    def has_at_exit_report?
      return true if ENV['DEPRECATABLE_HAS_AT_EXIT_REPORT'] == "true"
      return @has_at_exit_report
    end

    ##################################################################
    private
    ##################################################################

    def frequency_of( frequency )
      case frequency.to_s
      when 'always'
        (1.0/0.0)
      when 'once'
        1
      when 'never'
        0
      else
        Float(frequency).to_i
      end
    end
  end
end

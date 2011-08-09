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

    # Reset the options to their default values.
    #
    # Returns nothing.
    def reset
      @caller_context_padding = 2
      @has_at_exit_report     = true
      @alert_frequency        = 1
    end

    # Public: Set the number of lines of context surrounding the call site of
    # the deprecated method to display in the alerts and reports. (default: 2)
    #
    # count - The number of lines before and after the callsite to report.
    #         This must be a positive number.
    #
    # Returns the count.
    def caller_context_padding=( count )
      raise ArgumentError, "caller_content_padding must have a count > 0" unless count > 0
      @caller_context_padding = count
    end

    # Public: Get the number of lines of context padding.
    #
    # This may be overridden with the environment variable
    # DEPRECATABLE_CALLER_CONTEXT_PADDING.
    #
    # Returns the Integer number of context padding lines.
    def caller_context_padding
      p = ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING']
      if p then
        p = Float(p).to_i
        raise ArgumentError, "DEPRECATABLE_CALLER_CONTEXT_APDDING must have a value > 0, it is currently #{p}" unless p > 0
        return p
      end
      return @caller_context_padding
    end

    # Public: Set the maximum number of times an alert for a unqiue CallSite
    # of a DeprecatedMethod will be emitted. (default: :once)
    #
    # That is, when a deprecated method is called from a particular CallSite,
    # normally an 'alert' is sent. This setting controls the maximum number of
    # times that the 'alert' for a particular CallSite is emitted.
    #
    # freq - The alert frequency. This may be set to any number, or to one of
    #        the special token values:
    #
    #          :never  - Never send any alerts
    #          :once   - Send an alert for a given CallSite only once.
    #          :always - Send an alert for every invocation of the
    #                    DeprecatedMethod.
    #
    # Returns the alert_frequency.
    def alert_frequency=( freq )
      @alert_frequency = frequency_of( freq )
    end

    # Public: Get the current value of the alert_frequency.
    #
    # This may be overridden with the environment variable
    # DEPRECATABLE_ALERT_FREQUENCY.
    #
    # Returns the Integer value representing the alert_frequency.
    def alert_frequency
      p = ENV['DEPRECATABLE_ALERT_FREQUENCY']
      return frequency_of(p) if p
      return @alert_frequency
    end

    # Public: Set whether or not the final at_exit_report should be emitted
    #
    # bool - true or false, shall the exit report be emitted.
    #
    # Returns the value set.
    attr_writer :has_at_exit_report

    # Public: Say whether or not the final at exit report shall be emitted.
    #
    # This may be overridden by the environment variable
    # DEPRECATABLE_HAS_AT_EXIT_REPORT. Setting the environment variable to
    # 'true' will override the existing setting.
    #
    # Returns the boolean of whether or not the exti report should be done.
    def has_at_exit_report?
      return true if ENV['DEPRECATABLE_HAS_AT_EXIT_REPORT'] == "true"
      return @has_at_exit_report
    end

    ##################################################################
    private
    ##################################################################

    # Convert the given frequency Symbol/String into its Numeric representation.
    #
    # Return the Numeric value of the input frequency.
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

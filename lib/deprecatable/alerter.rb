require 'stringio'
module Deprecatable
  # An Alerter formats and emits alerts, and formats and emits reports.
  #
  # If you wish to impelement your own Alerter class, then it must implement
  # the following methods:
  #
  # * alert( DeprecatedMethod, CallSite )
  # * final_reort()
  #
  # These are the two methods that are invoked by the Deprecatable system at
  # various points.
  #
  class Alerter
    # Public: Alert that the deprecated method was invoked at a specific call
    # site.
    #
    # deprecated_method - an instance of DeprecatedMethod
    # call_site         - an instance of CallSite showing this particular
    #                     invocation
    #
    # Returns nothing.
    def alert( deprecated_method, call_site )
      lines = deprecated_method_report( deprecated_method, call_site )
      lines << "To turn this report off do one of the following:"
      lines << "* in your ruby code set `Deprecatable.options.alert_frequency = :never`"
      lines << "* set the environment variable `DEPRECATABLE_ALERT_FREQUENCY=\"never\"`"
      lines << ""
      lines.each { |l| warn_with_prefix l }
    end

    # Public: Render the final deprecation report showing when and where all
    # deprecated methods in the Registry were calld.
    #
    # registry - An instance of Deprecatable::Registry
    #            (default: Deprecatable.registry)
    #
    # Returns nothing.
    def final_report( registry = Deprecatable.registry )
      lines = [ "Deprecatable 'at_exit' Report",
                "=============================" ]
      lines << ""
      lines << "To turn this report off do one of the following:"
      lines << ""
      lines << "* in your ruby code set `Deprecatable.options.has_at_exit_report = false`"
      lines << "* set the environment variable `DEPRECATABLE_HAS_AT_EXIT_REPORT=\"false\"`"
      lines << ""

      registry.items.each do |dm|
        lines += deprecated_method_report( dm )
      end
      lines.each { |l| warn_without_prefix l }
    end

    ###################################################################
    private
    ###################################################################

    # Format a report of the data in a DeprecatedMethod
    #
    # dm        - A DeprecatedMethod instance
    # call_site - A CallSite instance (default :nil)
    #
    # Returns an Array of Strings which are the lines of the report.
    def deprecated_method_report( dm, call_site = nil )
      m = "`#{dm.klass}##{dm.method}`"
      lines = [ m ]
      lines << "-" * m.length
      lines << ""
      lines << "* Originally defined at #{dm.file}:#{dm.line_number}"

      if msg = dm.message then
        lines << "* #{msg}"
      end
      if rd = dm.removal_date then
        lines << "* Will be removed after #{rd}"
      end

      if rv = dm.removal_version then
        lines << "* Will be removed in version #{rv}"
      end
      lines << ""

      if call_site then
        lines += call_site_report( call_site )
      else
        dm.call_sites.each do |cs|
          lines += call_site_report( cs, true )
        end
      end
      return lines
    end

    # Format a report about a CallSite
    #
    # cs            - A CallSite instance
    # include_count - Should the report include the invocation count from the
    #                 CallSite instance. (default: false)
    #
    # Returns an Array of Strings which are the lines of the report.
    def call_site_report( cs, include_count = false )
      header = [ "Called" ]
      header << "#{cs.invocation_count} time(s)" if include_count
      header << "from #{cs.file}:#{cs.line_number}"

      lines = [ header.join(' ') ]
      lines << ""
      cs.formatted_context_lines.each do |l|
        lines << "    #{l.rstrip}"
      end
      lines << ""
      return lines
    end

    # Emit a warning message without a prefix to the message.
    #
    # Returns nothing.
    def warn_without_prefix( msg = "" )
      warn msg
    end

    # Emit a warning message WITH a prefix to the message.
    #
    # Returns nothing.
    def warn_with_prefix( msg = "" )
      warn "DEPRECATION WARNING: #{msg}"
    end

    # Emit a warning message.
    #
    # Returns nothing.
    def warn( msg )
      Kernel.warn( msg )
    end
  end

  # StringIOAlerter is used to capture all alerts in an instance of StringIO
  # instead of emitting them as Ruby warnings. This is mainly used in testing,
  # and may have uses in other situations too.
  class StringIOAlerter < Alerter
    # Initialize the StringIOAlerter
    #
    # Returns nothing.
    def initialize
      @stringio = StringIO.new
    end

    # Capture the warning into the StringIO instance
    #
    # Returns nothing.
    def warn( msg )
      @stringio.puts msg
    end

    # Access the contens of the internal StringIO instance.
    #
    # Returns a String containing all the warnings so far.
    def to_s
      @stringio.string
    end
  end
end

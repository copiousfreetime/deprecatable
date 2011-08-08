require 'stringio'
module Deprecatable
  # The Default Alerter for Deprecatable
  #
  # Any class can be an Alerter, it just needs to respond_to?( :alert )
  # The Alerter also doe the at_exit report, and that is done with the
  # 'final_report' which takes no arguments.
  class Alerter
    # alert that the deprecated method was invoked at a specific call site
    #
    # deprecated_method - an instance of DeprecatedMethod
    # call_site         - an instance of CallSite showing this particular
    #                     invocation
    # This just prints it out using the global 'warn' method
    def alert( deprecated_method, call_site )
      lines = deprecated_method_report( deprecated_method, call_site )
      lines << "To turn this report off do one of the following:"
      lines << "* in your ruby code set `Deprecatable.options.alert_frequency = :never`"
      lines << "* set the environment variable `DEPRECATABLE_ALERT_FREQUENCY=\"never\"`"
      lines << ""
      lines.each { |l| warn_with_prefix l }
    end

    # Render the final report
    def final_report
      lines = [ "Deprecatable 'at_exit' Report",
                "=============================" ]
      lines << ""
      lines << "To turn this report off do one of the following:"
      lines << ""
      lines << "* in your ruby code set `Deprecatable.options.has_at_exit_report = false`"
      lines << "* set the environment variable `DEPRECATABLE_HAS_AT_EXIT_REPORT=\"false\"`"
      lines << ""


      ::Deprecatable.registry.items.each do |dm|
        lines += deprecated_method_report( dm )
      end
      lines.each { |l| warn_without_prefix l }
    end

    ###################################################################
    private
    ###################################################################

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

    def warn_without_prefix( msg = "" )
      warn msg
    end

    def warn_with_prefix( msg = "" )
      warn "DEPRECATION WARNING: #{msg}"
    end

    def warn( msg )
      Kernel.warn( msg )
    end
  end

  class StringIOAlerter < Alerter
    def initialize
      @stringio = StringIO.new
    end

    def warn( msg )
      @stringio.puts msg
    end

    def to_s
      @stringio.string
    end
  end
end

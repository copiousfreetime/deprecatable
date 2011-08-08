module Deprecatable
  # The Default Alerter for Deprecatable
  #
  # Any class can be an Alerter, it just needs to respond_to?( :alert )
  class Alerter
    # alert that the deprecated method was invoked at a specific call site
    #
    # deprecated_method - an instance of DeprecatedMethod
    # call_site         - an instance of CallSite showing this particular
    #                     invocation
    # This just prints it out using the global 'warn' method
    def alert( deprecated_method, call_site )
      long = [ "Deprecated method:",
               "#{deprecated_method.klass.name}##{deprecated_method.method}",
               "invoked" ]
      warn long.join(' ')
      w = 20  
      warn "#{"defined at".rjust( w )} : #{deprecated_method.file}:#{deprecated_method.line_number}"
      warn "#{"called at".rjust( w )} : #{call_site.file}:#{call_site.line_number}"

      if rd = deprecated_method.removal_date then
        warn "#{"to be removed after".rjust(w)} : #{rd}"
      end

      if rv = deprecated_method.removal_version then
        warn "#{"to be removed in".rjust(w)} : Version #{rv}"
      end

      if msg = deprecated_method.message then
        warn "#{"developer message".rjust(w)} : #{msg}"
      end

      warn
      warn "Please go look at the following location and see if the code needs to be updated:"
      warn
      call_site.formatted_context_lines.each do |l|
        warn l.rstrip
      end
    end

      def warn( msg = "" )
        Kernel.warn( "DEPRECATION WARNING: #{msg}" )
      end
    end
  end

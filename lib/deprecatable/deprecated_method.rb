require 'deprecatable/util'
require 'deprecatable/call_site'
module Deprecatable
  # DeprecatedMethod holds all the information about a method that was marked
  # as 'deprecated' through the Deprecatable Module. The Class, method name,
  # and the file and line number of the deprecated method are stored in
  # DeprecatedMethod.
  #
  # It also is the location in which the calls to the deprected method are
  # stored. Each call to the deprecated method ends up with a call to
  # 'log_invocation'. The 'log_invocation' method records the CallSite of
  # where the deprecated method was called, and the number of times that the
  # deprecated method was called from that CallSite.
  #
  # In general, the first time a deprecated method is called from a particular
  # CallSite, the Alerter is invoked to report the invocation. All subsequent
  # calls to the deprecated method do not alert, although the invocation count
  # is increased. This behavior may be altered through the Deprecatable::Options
  # instance at Deprecatable.options.
  #
  class DeprecatedMethod
    include Util

    # Public: The Ruby class that has the method being deprecated.
    #
    # Returns the Class whos method is being deprecated.
    attr_reader :klass

    # Public: The method in the klass being deprecated.
    #
    # Returns the Symbol of the method being deprecated.
    attr_reader :method

    # Public: The filesystem path of the file where the deprecation took place.
    #
    # Returns the String path to the file.
    attr_reader :file

    # Public: The line number in the file where hte deprecation took place. This
    # is a 1 indexed value.
    #
    # Returns the Integer line number.
    attr_reader :line_number

    # Public: The additional message to output with the alerts and reports.
    #
    # Returns the String message.
    attr_reader :message

    # Public: The date on which the deprecate method will be removed.
    #
    # Returns the removal date.
    attr_reader :removal_date

    # Public: The version of the software which will no longer have the
    # deprecated method.
    #
    # Returns the version number.
    attr_reader :removal_version

    # The aliased name of the method being deprecated. This is what is called by
    # the wrapper to invoke the original deprecated method.
    #
    # Returns the String method name.
    attr_reader :deprecated_method_name

    # Create a new DeprecatedMethod.
    #
    # klass       - The Class containing the deprecated method.
    # method      - The Symbol method name of the deprecated method.
    # file        - The String filesystem path where the deprecation took place.
    # line_number - The Integer line in the file where hte deprecation took 
    #               place.
    # options     - The Hash optional parameters (default: {})
    #               :message         - A String to output along with the rest of
    #                                  the notifcations about the deprecated
    #                                  method.
    #               :removal_date    - The date on which the deprecated method
    #                                  will be removed.
    #               :removal_version - The version on which the deprecated 
    #                                  method will be removed.
    def initialize( klass, method, file, line_number, options = {} )
      @klass                  = klass
      @method                 = method
      @file                   = File.expand_path( file )
      @line_number            = Float(line_number).to_i
      @deprecated_method_name = "_deprecated_#{method}"
      @invocations            = 0
      @call_sites             = Hash.new
      @message                = options[:message]
      @removal_date           = options[:removal_date]
      @removal_version        = options[:removal_version]
      @to_s                   = nil
      insert_shim( self )
    end

    # Format the DeprecatedMethod as a String.
    #
    # Returns the DeprecatedMethod as a String.
    def to_s
      unless @to_s then
        target = @klass.kind_of?( Class ) ? "#{@klass.name}#" : "#{@klass.name}."
        @to_s = "#{target}#{@method} defined at #{@file}:#{@line_number}"
      end
      return @to_s
    end

    # Log the invocation of the DeprecatedMethod at the given CallSite. Alert
    # the media.
    #
    # file        - The String path to the file in which the DeprecatedMethod
    #               was invoked.
    # line_number - The Integer line_number in the file on which the
    #               DeprecatedMethod was invoked.
    #
    # Returns nothing.
    def log_invocation( file, line_number )
      call_site = call_site_for( file, line_number )
      call_site.increment_invocation_count
      alert( call_site )
    end

    # Tell the Deprecatable.alerter to alert if the number of invocations at the
    # CallSite is less than or equal to the alert frequency.
    #
    # call_site - The CallSite instance representing where this DeprecatedMethod
    #             was invoked.
    #
    # Returns nothing.
    def alert( call_site )
      if call_site.invocation_count <= ::Deprecatable.options.alert_frequency then
        ::Deprecatable.alerter.alert( self, call_site )
      end
    end

    # Gets the lines of all the CallSites where this DeprecatedMethod was
    # invoked.
    #
    # Returns an Array of CallSite instances.
    def call_sites
      @call_sites.values
    end

    # Gets the sum total of all the invocations of this DeprecatedMethod.
    #
    # Returns the Integer count of invocations.
    def invocation_count
      sum = 0
      @call_sites.values.each { |cs| sum += cs.invocation_count }
      return sum
    end

    # Gets the unique count of CallSites representing the unique number of
    # locations where this DeprecatedMethod was invoked.
    #
    # Returnts the Integer unique count of CallSites.
    def call_site_count
      @call_sites.size
    end

    ###################################################################
    private
    ###################################################################

    # Find the CallSite representing the given file and line_number. It creates
    # a new CallSite instance if necessary.
    #
    # file        - The String path to the file in which the DeprecatedMethod
    #               was invoked.
    # line_number - The Integer line_number in the file on which the
    #               DeprecatedMethod was invoked.
    #
    # Returns the CallSite representing the give file and line number.
    def call_site_for( file, line_number )
      cs = @call_sites[CallSite.gen_key( file, line_number)]
      if cs.nil? then
        cs = CallSite.new( file, line_number, ::Deprecatable.options.caller_context_padding  )
        @call_sites[cs.key] = cs
      end
      return cs
    end

    # Create the wrapper method that replaces the deprecated method. This is
    # where the magic happens.
    #
    # This does the following:
    #
    # 1) aliases the deprecated method to a new method name
    # 2) creates a new method with the original name that
    #    1) logs the invocation of the deprecated method 
    #    2) calls the original deprecated method.
    #
    # Returns nothing.
    def insert_shim( dm )
      if not klass.method_defined?( dm.deprecated_method_name ) then

        klass.module_eval do

          alias_method dm.deprecated_method_name, dm.method

          define_method( dm.method ) do |*args, &block|
            dm.log_invocation( *Util.location_of_caller )
            send( dm.deprecated_method_name, *args, &block )
          end

        end
      end
    end
  end
end

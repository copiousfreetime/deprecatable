require 'deprecatable'
require 'deprecatable/util'
require 'deprecatable/call_site'
module Deprecatable
  # DeprecatedMethod holds all the information about a method that was marked
  # as 'deprecated' through the Deprecatable Module. The Class, method name,
  # and the file and line number of the deprecated method are stored in
  # DeprecatedMethod.
  #
  # It also is the location in which the calls to the deprected method are
  # stored. Each call to the deprecated method ends up with a call to 'mark'.
  # The 'mark' method records the origin location of where the deprecated method
  # was called, and the number of times that the deprecated method was called
  # from that origin location.
  #
  # The first time a deprecated method is called from a particular origin, the
  # alert mechanism is invoked to tell the caller that they have called a
  # deprecatd method. All subsequent calls to the deprecated method do not
  # alert, and the invocation count of that call is increased.
  class DeprecatedMethod
    include Util

    # The ruby class that has the method being deprecated
    attr_reader :klass

    # The method in the klass being deprecated
    attr_reader :method

    # The physical file in which the deprecated method was marked as deprecated
    attr_reader :file

    # The line number in the file in which the deprecated method was marked as
    # deprecated. Line numbers start at 1
    attr_reader :line_number

    # An additional message to output with the alerts for this deprecated metho
    attr_reader :message

    # A possible removal date for when this deprecated method will be removed
    # from the system
    attr_reader :removal_date

    # A possible removal version for when this deprecated method will be removed
    attr_reader :removal_version

    # When a method is deprecated, it is renamed and then wrapped. This is the
    # rename of the original deprecated method.
    attr_reader :deprecated_method_name

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

    # return a string showing deprecated method and its location
    def to_s
      unless @to_s then
        target = @klass.kind_of?( Class ) ? "#{@klass.name}#" : "#{@klass.name}."
        @to_s = "#{target}#{@method} defined at #{@file}:#{@line_number}"
      end
      return @to_s
    end

    def log_invocation( file, line_number )
      call_site = call_site_for( file, line_number )
      call_site.increment_invocation_count
      alert( call_site )
    end

    def alert( call_site )
      if call_site.invocation_count <= ::Deprecatable.options.alert_frequency then
        ::Deprecatable.alerter.alert( self, call_site )
      end
    end

    # return the CallSite objects
    def call_sites
      @call_sites.values
    end

    # return the total number of invocations of the given method
    def invocation_count
      sum = 0
      @call_sites.values.each { |cs| sum += cs.invocation_count }
      return sum
    end

    # return the total number of unique call sites for this method
    def call_site_count
      @call_sites.size
    end


    ###################################################################
    private
    ###################################################################
    def call_site_for( file, line_number )
      cs = @call_sites[CallSite.gen_key( file, line_number)]
      if cs.nil? then
        cs = CallSite.new( file, line_number, ::Deprecatable.options.caller_context_padding  )
        @call_sites[cs.key] = cs
      end
      return cs
    end


    # Create the wrapper around the original method that records the invocation
    # and then deletages to the original method
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

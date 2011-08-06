require 'deprecatable/util'
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

    attr_reader :klass, :method, :file, :line
    attr_reader :invocations, :deprecated_method_name

    def initialize( klass, method, file, line, options = {} )
      @klass                  = klass
      @method                 = method
      @file                   = file
      @line                   = Float(line).to_i
      @namespace              = options[:namespace] || default_namespace( klass )
      @invocations            = Hash.new( 0 )
      @deprecated_method_name = "_deprecated_#{method}"
    end

    # return a string showing deprecated method and its location
    def to_s
      unless @to_s then
        target = @klass.kind_of?( Module) ? "#{@klass}." : "#{@klass.class}#"
        @to_s = "#{target}#{@method} at #{@file}:#{line}"
      end
      return @to_s
    end


    # Record a call to a deprecated method. On the first call from a new call
    # site, do the alerting.
    #
    # file - The file from which the call was made.
    # line - The line in the file from which the call was made.
    #
    # Returns nothing.
    def mark( file, line )
      count = @invocations["#{file}:#{line}"] += 1
      alert( file, line ) if count == 1
    end

    # Output using ruby warnings that someone has called a deprecated method.
    #
    # file - The full pathname to the file in which the call site is located.
    # line - The line number in the file.
    #
    # Returns nothing
    def alert( file, line )
      line = Float(line).to_i
      _warn "Deprecated method #{klass}##{method} called at #{file}:#{line}"
      report_caller_context( file, line )
    end

    # Output using ruby warnings the caller context, if there is any.
    #
    # file - The full pathname to the file in which the call site is located.
    # line - The line number in the file.
    #
    # Returns nothing
    def report_caller_context( file, line )
      context = caller_context( file, line )
      if context.size > 0 then
        _warn "Please go look at the following location and see if the code needs to be updated:"
        _warn
        context.each do |line|
          _warn line
        end
        _warn
      end
    end

    # Generate the caller context as an Array of Strings.
    #
    # file   - The full pathname to the file in which the call site is located.
    # lineno - The line number in the file. Lines in files start at 1, not 0.
    #
    # Returns an array of strings that format a nice context around the line in
    # question.
    #
    def caller_context( file, lineno )
      if File.readable?( file ) then
        line_index    = lineno - 1
        caller_lines  = IO.readlines( file )
        context       = [ "Location: #{file}:#{line}" ]
        start_line    = line_index  - Deprecatable.options.caller_context_padding
        count         = (2 * Deprecatable.options.caller_context_padding) + 1
        lines         = caller_lines[start_line, count]
        number_width  = ("%d" % (start_line + count)).length

        count.times do |x|
          this_line = start_line + x
          prefix    = this_line == line_index ?  "--->" : " "*4
          number    = ("%d" % this_line).rjust( number_width )
          lines[x]  = "#{prefix} #{number}: #{lines[x]}"
        end
        context << lines
        return context.flatten
      end
      return []
    end

    # A helper method to send data out using ruby warnings
    def _warn( msg = "" )
      warn "WARNING: #{msg.rstrip}"
    end

    def default_namespace( klass )
      return klass.to_s.split('::').first
    end
  end
end


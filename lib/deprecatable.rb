# Allow methods to be deprecated and record when they are called. Each method
# that is marked via the deprecated class method is wrapped, and calls to the 
# deprececated method are recorded.
#
# There are configurable options for the extended class:
#
# _dp_caller_context_padding - the number of lines pre and post the call site
#                              that are reported the first time the deprecated
#                              method is invoked from a particular call site.
#                              (The default is 3).
#
# For example:
#
#   class Foo
#     extend Deprecatable
#
#     def bar
#       ...
#     end
#
#     deprecate :bar
#
#     # configuration options for the Deprecatable class
#     # These are stored on a per-extended-class level
#     _dp_caller_context_padding 5
#
#   end
#

module Deprecatable
  VERSION = '1.0.0'

  # Common utility functions used by all the Deprecatable modules and classes
  module Util
    def _dp_call_origin( stack, skip_after = nil )
      file, line = nil, nil
      loop do
        file, line, _ = stack.shift.split(':')
        file = File.expand_path( file )
        break unless skip_after
        skip_after = nil if skip_after == file 
      end
      return file, line
    end
  end

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

    def initialize( klass, method, file, line )
      @klass, @method, @file, @line = klass, method, file, line
      @line = Float(line).to_i
      @invocations = Hash.new( 0 )
      @deprecated_method_name = "_deprecated_#{method}"
    end
    
    def to_s
      "#{klass}##{method} at #{file}:#{line}"
    end

    # Record a call to a deprecated method. On the first call from a new call
    # site, do the alerting.
    #
    # stack - The call stack to mark. This defaults to the current call stack
    #
    # Returns nothing.
    def mark( stack = caller )
      file, line = _dp_call_origin( stack, File.expand_path( __FILE__ ) )
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
    # file - The full pathname to the file in which the call site is located.
    # line - The line number in the file.
    #
    # Returns an array of strings that format a nice context around the line in
    # question.
    #
    def caller_context( file, line )
      if File.readable?( file ) then
        caller_lines  = IO.readlines( file )
        context       = [ "Location: #{file}:#{line}" ]
        start_line    = line - klass._dp_caller_context_padding
        count         = (2* klass._dp_caller_context_padding)+1
        lines         = caller_lines[start_line, count]
        number_width  = ("%d" % (start_line + count)).length

        count.times do |x| 
          this_line = start_line + x
          prefix    = this_line == line ?  "--->" : " "*4
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
  end


  include Util

  def deprecate( method_name )
    file, line = _dp_call_origin( caller )
    dm         = _dp_register_deprecated_method( method_name, file, line )

    if not method_defined?( dm.deprecated_method_name ) then
      alias_method dm.deprecated_method_name, method_name

      define_method( method_name ) do |*args|
        dm.mark
        send( dm.deprecated_method_name, *args )
      end

    end
  end

  #--------------------------------------
  # Here there be dragons
  #--------------------------------------

  # Register a method in the current class definition to be deprecated.
  # 
  # method - The method to deprecate.
  # file   - The file in which the deprecated method is defined.
  # line   - The line number in the file on which the method is defined.
  #
  # Returns the DeprecatedMethod instance created.
  def _dp_register_deprecated_method( method, file, line )
    dm = DeprecatedMethod.new( self, method, file, line )
    _dp_registry[dm] = true
    return dm
  end

  # Blank out the current registry
  def _dp_reset
    _dp_registry.clear
  end

  # Return the current registry
  def _dp_registry
    @_dp_registry ||= Hash.new
  end

  # When displaying the deprecation call site, this is the number of lines of
  # output on either side of the call site to print out.
  def _dp_caller_context_padding
    @_dp_caller_context_width = 2
  end
  def _dp_caller_context_padding=( count )
    @_dp_caller_context_width = count
  end
end

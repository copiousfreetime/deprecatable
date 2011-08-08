require 'deprecatable/call_site_context'
module Deprecatable
  # CallSite represents a location in the source code where a DeprecatedMethod
  # was invoked. It contains the location of the call site, the number of times
  # that it was invoked, and an extraction of the source code around the
  # invocation site
  class CallSite
    # Generate the hash key for a call site with the given file and line number
    def self.gen_key( file, line_number )
      "#{file}:#{line_number}"
    end

    # The fully expanded path of the file
    attr_reader :file

    # The line number in the file of the call site. Line numbers start at 1
    attr_reader :line_number

    # The number of lines of padding before and after to also capture when
    # getting the context
    attr_reader :context_padding

    # The number of times this call site has been invoked
    attr_reader :invocation_count

    def initialize( file, line_number, context_padding )
      @file             = File.expand_path( file )
      @line_number      = line_number
      @context_padding  = context_padding
      @invocation_count = 0
    end

    # return the hash key for this call site
    def key
      CallSite.gen_key( file, line_number )
    end

    # increment the invocation count by the amount given
    #
    # count - the amount to increment the invocation count by
    #         This should rarely, if ever be set.
    #
    # returns the invocation count
    def increment_invocation_count( count = 1 )
      @invocation_count += count
    end

    # Retrieve the call site context. This goes to the source file, finds the
    # right lines of the file ane captures them with some annotation
    #
    # returns an instances of CallSiteContext
    def context
      @context ||= CallSiteContext.new( @file, @line_number, @context_padding )
    end

    # Return the context lines
    def context_lines
      context.context_lines
    end

    # return the formatted context lines
    def formatted_context_lines
      context.formatted_context_lines
    end
  end
end

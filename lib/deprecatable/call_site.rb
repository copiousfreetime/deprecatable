require 'deprecatable/call_site_context'
module Deprecatable
  # CallSite represents a location in the source code where a DeprecatedMethod
  # was invoked. It contains the location of the call site, the number of times
  # that it was invoked, and an extraction of the source code around the
  # invocation site
  class CallSite
    # Generate the hash key for a call site with the given file and line
    # number.
    #
    # file        - A String that is the filesystem path to a file.
    # line_number - An Integer that is the line number in the given file.
    #
    # Returns a String that is generally used as a unique key.
    def self.gen_key( file, line_number )
      "#{file}:#{line_number}"
    end

    # Public: Get the fully expand path of the file of the CallSite
    #
    # Returns the String filesystem path of the file.
    attr_reader :file

    # Public: Get the line number of the CallSite in the file.
    # Line numbers start at 1.
    #
    # Returns the line number of a line in the file.
    attr_reader :line_number

    # Public: Gets the number of lines before and after the line_nubmer
    # to also capture when gettin the context.
    #
    # This number is the number both before AND after 'line_number' to
    # capture. If this number is 2, then the total number of lines captured
    # should be 5. 2 before, the line in question, and 2 after.
    #
    # Returns the number of lines
    attr_reader :context_padding

    # Public: The number of times this CallSite has been invoked.
    #
    # Returns the Integer number of times this call site has been invoked.
    attr_reader :invocation_count

    # Create a new instance of CallSite
    #
    # file            - A String pathname of the file where the CallSite
    #                   happend
    # line_number     - The Integer line number in the file.
    # context_padding - The Integer number of lines both before and after
    #                   the 'line_nubmer' to capture.
    def initialize( file, line_number, context_padding )
      @file             = File.expand_path( file )
      @line_number      = line_number
      @context_padding  = context_padding
      @invocation_count = 0
    end

    # The unique identifier of this CallSite.
    #
    # Returns the String key of this CallSite.
    def key
      CallSite.gen_key( file, line_number )
    end

    # Increment the invocation count by the amount given
    #
    # count - The amount to increment the invocation count by
    #         This should rarely, if ever be set.
    #         (default: 1)
    #
    # Returns the Integer invocation count.
    def increment_invocation_count( count = 1 )
      @invocation_count += count
    end

    # Retrieve the lazily loaded CallSiteContext.
    #
    # Returns an instances of CallSiteContext
    def context
      @context ||= CallSiteContext.new( @file, @line_number, @context_padding )
    end

    # Access the lines of the context in a nicely formatted way.
    #
    # Returns an Array of Strings containing the formatted context.
    def formatted_context_lines
      context.formatted_context_lines
    end
  end
end

module Deprecatable
  # CallSiteContext captures the actual file context of the call site.
  # It goes to the source file and extracts the lines around the line in
  # question with the given padding and keeps it available for emitting
  class CallSiteContext
    # Public: The raw lines from the source file containing the context.
    #
    # Returns an Array of Strings of the lines from the file.
    attr_reader :context_lines

    # Public: The raw line numbers from the source file. The lines of
    # a source file start with 1. This is a parallel array to 'context_lines'
    #
    # Returns an Array of Integers of the line numbers from the flie.
    attr_reader :context_line_numbers

    # The marker used to prefix the formatted context line of the exact line of
    # the context where the CallSite took place
    #
    # Returns a String.
    def self.pointer
      "--->"
    end

    # The prefix to put in front of the CallSite context padding lines.
    #
    # Returns a String of blanks the same length as 'pointer'
    def self.not_pointer
      " " * pointer.length
    end

    # Create a new CallSiteContext. Upon instantiation, this will go to the
    # source file in question, and extract the CallSite line and a certain
    # number of 'padding' lines around it.
    #
    # file        - The String pathname of the file from which to extract lines.
    # line_number - The 1 indexed line number within the file to be the center
    #               of the extracted context.
    # padding     - The Number of lines before and after 'line_number' to
    #               extract along with the text at 'line_number'
    #
    # Returns nothing.
    def initialize( file, line_number, padding )
      @file                 = file
      @line_number          = line_number
      @padding              = padding

      @context_line_numbers    = []
      @context_lines           = []
      @context_index           = @padding + 1
      @formatted_context_lines = []

      extract_context()
    end

    # Nicely format the context lines extracted from the file.
    #
    # Returns an Array of Strings containing the formatted lines.
    def formatted_context_lines
      if @formatted_context_lines.empty? then
        number_width = ("%d" % @context_line_numbers.last).length
        @context_lines.each_with_index do |line, idx|
          prefix = (idx == @context_index) ? CallSiteContext.pointer : CallSiteContext.not_pointer
          number = ("%d" % @context_line_numbers[idx]).rjust( number_width )
          @formatted_context_lines << "#{prefix} #{number}: #{line}"
        end
      end
      return @formatted_context_lines
    end

    ###########################################################################
    private
    ###########################################################################

    # Extract the context from the source file. This goes to the file in
    # question, and extracts the line_number and the padding lines both
    # before and after the line_number. If the padding would cause the context
    # to go before the first line of the file, or after the last line of the
    # file, the padding is truncated accordingly.
    #
    # The result of this operation is the setting of many instance
    # variables
    #
    #   @context_lines        - An Array of String containging the line_number
    #                           line from the file and the 'padding' lines
    #                           before and after it.
    #   @context_index        - The index into @context_lines of the
    #                           line_number line from the file
    #   @context_line_numbers - An Array of Integers that paralles
    #                           @context_lines contianing the 1 indexed line
    #                           numbers from the file corresponding to the lines
    #                           in @context_lines.
    #
    # Returns nothing.
    def extract_context
      if File.readable?( @file ) then
        file_lines            = IO.readlines( @file )
        @line_index           = @line_number - 1

        start_line            = @line_index - @padding
        start_line            = 0 if start_line < 0

        stop_line             = @line_index + @padding
        stop_line             = (file_lines.size - 1) if stop_line >= file_lines.size

        @context_index        = @line_index - start_line
        @context_line_numbers = (start_line+1..stop_line+1).to_a
        @context_lines        = file_lines[start_line, @context_line_numbers.size]
      end
    end
  end
end

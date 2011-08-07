module Deprecatable
  # CallSiteContext captures the actual file context of the call site.
  # It goes to the source file and extracts the lines around the line in
  # question with the given padding and keeps it available for emitting
  class CallSiteContext
    # the location header for formatted output
    attr_reader :location_header

    # the array of lines from the file that have the context
    attr_reader :context_lines

    def self.pointer
      "--->"
    end

    def self.not_pointer
      " " * pointer.length
    end

    def initialize( file, line_number, padding )
      @file                 = file
      @line_number          = line_number
      @padding              = padding
      @location_header      = "Location: #{file}:#{line_number}"

      @context_line_numbers = []
      @context_lines        = []
      @context_index        = @padding + 1
      extract_context()
    end

    def formatted_context_lines
      fc = [ @location_header ]
      number_width = ("%d" % @context_line_numbers.last).length
      @context_lines.each_with_index do |line, idx|
        prefix = (idx == @context_index) ? CallSiteContext.pointer : CallSiteContext.not_pointer
        number = ("%d" % @context_line_numbers[idx]).rjust( number_width )
        fc << "#{prefix} #{number}: #{line}"
      end
      return fc
    end

    private
    # Extract the context from the source file
    #
    # The result of this operation is the setting of many instance
    # variables
    #
    #   @context_lines        - the lines from the file surrounding the
    #                           line we want
    #   @context_index        - the index into @context_lines of the line
    #                           we want
    #   @context_line_numbers - a parallel array of the line numbers from
    #                           the file for the lines in @context_lines
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

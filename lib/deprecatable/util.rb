module Deprecatable
  # Common utility functions used by all the Deprecatable modules and classes
  module Util
    # The file name and line number of the caller of the caller of this method.
    def self.location_of_caller
      call_line     = caller[1]
      file, line, _ = call_line.split(':')
      file          = File.expand_path( file )
      line          = Float(line).to_i
      return file, line
    end
  end
end



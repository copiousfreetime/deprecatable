module Deprecatable
  # Common utility functions used by all the Deprecatable modules and classes
  module Util
    # Find the caller of the method that called the method where
    # location_of_call was invoked. In other words:
    #
    #     def foo
    #       bar()  # <--- this file and line number is returned
    #     end
    #
    #     def bar
    #       Deprecatable::Util.location_of_caller
    #     end
    #
    # return the file and line number from which bar() was invoked.
    def self.location_of_caller
      call_line     = caller[1]
      file, line, _ = call_line.split(':')
      file          = File.expand_path( file )
      line          = Float(line).to_i
      return file, line
    end
  end
end



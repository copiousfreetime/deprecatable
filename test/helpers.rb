require 'minitest/autorun'
require 'deprecatable'

::Deprecatable.options.has_at_exit_report = false

module MiniTest
  class Unit
    class TestCase
      def assert_array_equal( expected, actual, msg = nil )
        assert_equal( expected.size, actual.size, msg )
        expected.each_with_index do |i, idx|
          assert_equal( i, actual[idx], msg )
        end
      end
    end
  end
end

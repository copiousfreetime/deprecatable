require "helpers"

class TestDeprecatableUtil < MiniTest::Unit::TestCase
  def i_was_called
    Deprecatable::Util.location_of_caller
  end

  def test_location_of_caller
    file, line = i_was_called
    assert_equal( File.expand_path(__FILE__), file )
    assert_equal( 10, line )
  end
end

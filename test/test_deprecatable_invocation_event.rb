require "minitest/autorun"
require "deprecatable/deprecated_method"
require "deprecatable/invocation_event"

class TestDeprecatableInvocationEvent < MiniTest::Unit::TestCase
  def test_initializes
    dm = Deprecatable::DeprecatedMethod.new( TestDeprecatableInvocationEvent, "test_initializes", __FILE__, __LINE__ )
    event = Deprecatable::InvocationEvent.new( dm, File.expand_path( __FILE__ ), __LINE__ )
    assert_equal( dm, event.deprecated_method )
    assert_equal( File.expand_path( __FILE__ ), event.caller_file )
    assert_equal( 8, event.caller_line_number )
  end
end



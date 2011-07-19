require "minitest/autorun"
require "deprecatable/options"

class TestDeprecatableOptions < MiniTest::Unit::TestCase

  def setup
    @options = Deprecatable::Options.new
  end

  def test_defaults_exist
    assert_equal( 2, @options.caller_context_padding )
    assert_equal( true, @options.at_exit_report? )
  end

  def test_caller_context_padding_raises_error_if_set_to_negative_number
    assert_raises( ArgumentError, "caller_context_mapping must be >= 0" ) do 
      @options.caller_context_padding = -1
    end
  end

  def test_caller_context_padding_may_be_set
    @options.caller_context_padding = 4
    assert_equal( 4, @options.caller_context_padding )
  end

  def test_at_exit_report_may_be_turned_off
    @options.at_exit_report = false
    refute @options.at_exit_report?, "at_exit_report? must be false"
  end

end

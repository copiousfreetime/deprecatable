require "minitest/autorun"
require "deprecatable/options"

class TestDeprecatableOptions < MiniTest::Unit::TestCase

  def setup
    @options = Deprecatable::Options.new
  end

  def teardown
    ENV.keys.each do |k|
      next unless k =~/^DEPRECATABLE/
      ENV.delete( k )
    end
  end

  def test_defaults_exist
    assert_equal( 2    , @options.caller_context_padding )
    assert_equal( true , @options.has_at_exit_report?    )
    assert_equal( 1    , @options.alert_frequency        )
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

  def test_caller_context_padding_may_be_overridden_by_environment_variable
    assert_equal( 2, @options.caller_context_padding )
    @options.caller_context_padding = 4
    assert_equal( 4, @options.caller_context_padding )
    ENV['DEPRECATABLE_CALLER_CONTEXT_PADDING'] = "10"
    assert_equal( 10, @options.caller_context_padding )
  end

  def test_has_at_exit_report_may_be_turned_off
    @options.has_at_exit_report = false
    refute @options.has_at_exit_report?, "has_at_exit_report? must be false"
  end

  def test_has_at_exit_report_may_be_overridden_by_environment_variable
    @options.has_at_exit_report = false
    refute @options.has_at_exit_report?
    ENV['DEPRECATABLE_HAS_AT_EXIT_REPORT'] = "true"
    assert @options.has_at_exit_report?, "has_at_exit_report? must be true"
  end

  def test_alert_frequency_may_be_set
    @options.alert_frequency = :once
    assert_equal( 1, @options.alert_frequency )

    @options.alert_frequency = :never
    assert_equal( 0, @options.alert_frequency )

    @options.alert_frequency = :always
    assert_equal( "Infinity", @options.alert_frequency.to_s )
    assert @options.alert_frequency.infinite?
  end

  def test_alert_frequency_may_be_overridden_by_environment_variable
    ENV['DEPRECATABLE_ALERT_FREQUENCY'] = "42"
    assert_equal( 42, @options.alert_frequency)
    ENV['DEPRECATABLE_ALERT_FREQUENCY'] = "once"
    assert_equal( 1, @options.alert_frequency)
    ENV['DEPRECATABLE_ALERT_FREQUENCY'] = "never"
    assert_equal( 0, @options.alert_frequency)
    ENV['DEPRECATABLE_ALERT_FREQUENCY'] = "always"
    assert @options.alert_frequency.infinite?
  end

end

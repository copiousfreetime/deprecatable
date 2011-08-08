require 'helpers'

class TestDeprecatableAlerter < MiniTest::Unit::TestCase
  def setup
    Deprecatable.registry.clear
    Deprecatable.options.reset

    @old_alerter = Deprecatable.alerter
    @alerter = ::Deprecatable::StringIOAlerter.new
    Deprecatable.alerter = @alerter

    @deprecated_class = Class.new do
      extend Deprecatable
      def self.name
        "TestDeprecatable::DeprecateMe"
      end
      def deprecate_me; end
      deprecate :deprecate_me
    end
  end

  def teardown
    Deprecatable.alerter = @old_alerter
  end

  def test_alert
    i = @deprecated_class.new
    i.deprecate_me

    assert_match( /---> #{__LINE__ - 2}:/, Deprecatable.alerter.to_s )
  end

  def test_final_report
    i = @deprecated_class.new
    12.times { i.deprecate_me }
    10.times { i.deprecate_me }
    Deprecatable.alerter.final_report
    assert_match( /Called 12 time/, Deprecatable.alerter.to_s )
    assert_match( /Called 10 time/, Deprecatable.alerter.to_s )
  end
end

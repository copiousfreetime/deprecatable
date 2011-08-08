require "helpers"

class TestDeprecatable < MiniTest::Unit::TestCase

  def setup
    Deprecatable.registry.clear
    Deprecatable.options.reset

    @deprecated_class = Class.new do
      extend Deprecatable
      def self.name
        "TestDeprecatable::DeprecateMe"
      end
      def deprecate_me; end
      deprecate :deprecate_me
    end

    @deprecatable_class = Class.new do
      extend Deprecatable
      def self.name
        "TestDeprecatable::DeprecatableClass"
      end
      def deprecate_me; end
    end
  end

  def test_deprecated_method_is_regsitered
    assert_equal( 1, Deprecatable.registry.size )
  end

  def test_call_site_is_recorded
    i = @deprecated_class.new
    capture_io do
      i.deprecate_me
    end
    assert_equal( 1, Deprecatable.registry.items.first.invocation_count )
  end

  def test_different_call_sites_are_recorded_independently
    i = @deprecated_class.new
    capture_io do
      42.times { i.deprecate_me }
      24.times { i.deprecate_me }
    end
    dm = Deprecatable.registry.items.first
    assert_equal( 66, dm.invocation_count )
    assert_equal( 2, dm.call_site_count )
  end

  def test_alerts_are_issued_only_once_for_a_callsite
    i = @deprecated_class.new
    callable = lambda { |c| c.deprecate_me }
    stdout, stderr = capture_io do
      callable.call( i )
    end
    line = __LINE__ - 4

    assert_match( /#{File.expand_path( __FILE__ )}:#{line}/m, stderr )
      assert_match( /---> #{line}:\s+callable = lambda \{ |c| c\.deprecate_me \}/, stderr )

    assert_silent do
      callable.call( i )
    end
  end

  def test_alerts_are_issued_never_for_a_callsite
    ::Deprecatable.options.alert_frequency = :never
    i = @deprecated_class.new
    assert_silent do
      i.deprecate_me
    end
  end

  def test_alerts_are_issued_for_every_call_to_a_callsite
    ::Deprecatable.options.alert_frequency = :always
    i = @deprecated_class.new
    stdout, stderr = capture_io do
      42.times { i.deprecate_me }
    end
    line = __LINE__ - 2
    lines = stderr.split(/\n/)
    assert_equal( 84, lines.grep( /#{File.expand_path( __FILE__)}:#{line}/ ).size )
      assert_equal( 42, lines.grep( /--->/ ).size )
  end

  def test_raise_an_exception_if_deprecating_a_method_that_does_not_exist
    assert_raises( NameError ) do
      @deprecatable_class.deprecate :wibble
    end
  end

  def assert_alert_match( regex, klass, &block )
    stdout, stderr = capture_io do
      i = klass.new
      i.deprecate_me
    end
    assert_match( regex, stderr )
    return stderr
  end

  def test_adds_an_additional_message_when_given
    @deprecatable_class.deprecate :deprecate_me, :message => "You should switch to using Something#bar"
    assert_alert_match( /developer message : .* Something#bar/m, @deprecatable_class )
  end

  def test_adds_a_removal_date_when_given
    @deprecatable_class.deprecate :deprecate_me, :removal_date => "2011-09-02"
    assert_alert_match( /to be removed after : 2011-09-02/m, @deprecatable_class )
  end

  def test_adds_a_removal_version_when_given
    @deprecatable_class.deprecate :deprecate_me, :removal_version => "4.2"
    assert_alert_match( /to be removed in : Version 4.2/m, @deprecatable_class )
  end

  def test_deprecating_an_included_method
    mod = Module.new do
      extend Deprecatable
      def deprecate_me; end
      deprecate :deprecate_me, :message => "KABOOM!"
    end
    klass = Class.new do
      include mod
    end

    assert_alert_match( /KABOOM!/, klass )
  end

  def test_deprecating_a_class_method
    klass = Class.new do
      class << self
        extend Deprecatable
        def deprecate_me; end
        deprecate :deprecate_me, :message => "Class Method KABOOM!"
      end
    end

    stdout, stderr = capture_io do
      klass.deprecate_me
    end
    assert_match( /Class Method KABOOM/, stderr )
  end
end

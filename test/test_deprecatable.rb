require "minitest/autorun"
require "deprecatable"

class TestDeprecatable < MiniTest::Unit::TestCase

  def setup
    Deprecatable.registry.clear

    @deprecated_class = Class.new do
      extend Deprecatable
      def deprecate_me; end
      deprecate :deprecate_me
    end
  end

  def test_deprecated_method_is_regsitered
    assert_equal( 1, Deprecatable.registry.size )
  end

  def test_call_site_is_recorded
    i = @deprecated_class.new
    i.deprecate_me
    assert_equal( 1, Deprecatable.registry.items.first.invocation_count )
  end

  def test_different_call_sites_are_recorded_independently
    i = @deprecated_class.new
    42.times { i.deprecate_me }
    24.times { i.deprecate_me }
    dm = Deprecatable.registry.items.first
    assert_equal( 66, dm.invocation_count )
    assert_equal( 2, dm.call_site_count )
  end
end

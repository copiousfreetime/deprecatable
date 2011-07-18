require "minitest/autorun"
require "deprecatable"

class TestDeprecatable < MiniTest::Unit::TestCase

  extend Deprecatable

  def deprecate_me; end
  deprecate :deprecate_me

  def setup
    @dp_registry = self.class._dp_registry
    @dm = @dp_registry.keys.first
  end

  def test_deprecate_origin_is_recorded
    deprecate_me
    file, line = File.expand_path(__FILE__), __LINE__ - 1
    assert_equal( 1, @dp_registry.size )
    assert_equal( "#{file}:#{line}", @dm.invocations.keys.first.to_s )
  end
end

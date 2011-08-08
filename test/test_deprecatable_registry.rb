require 'minitest/autorun'
require 'deprecatable/registry'
require 'deprecatable/deprecated_method'

class TestDeprecatableRegistry < MiniTest::Unit::TestCase
  class DeprecatedExample
    def boom; end
  end

  def setup
    @registry = Deprecatable::Registry.new
    @dm       = Deprecatable::DeprecatedMethod.new( TestDeprecatableRegistry::DeprecatedExample, "boom", __FILE__, 6 )
  end

  def test_registers_a_deprecated_method
    assert_equal( 0, @registry.size )
    @registry.register( @dm )
    assert_equal( 1, @registry.size )
  end

  def test_that_a_given_method_may_only_be_registered_once
    assert_equal( 0, @registry.size )
    @registry.register( @dm )
    assert_equal( 1, @registry.size )
    @registry.register( @dm )
    assert_equal( 1, @registry.size )
  end

  def test_returns_all_the_items_in_the_registry
    @registry.register( @dm )
    assert_equal( 1, @registry.items.size )
  end

end

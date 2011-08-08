require "minitest/autorun"
require "deprecatable/deprecated_method"


class TestDeprecatableDeprecatedMethod < MiniTest::Unit::TestCase
  def setup
    @klass = Class.new do
      def self.name
        "TestDeprecatableDeprecatedMethod::DeprecatableClass"
      end
      def m1
        "m1"
      end
    end

    @module = Module.new do
      def self.name
        "TestDeprecatableDeprecatedMethod::DeprecatableModule"
      end
      def m2; "m2"; end
    end

    @dep_class = Deprecatable::DeprecatedMethod.new( @klass, "m1", __FILE__, 7 )
  end

  def test_records_meta_information_about_the_deprecation
    assert_equal( @klass                       , @dep_class.klass                  )
    assert_equal( "m1"                         , @dep_class.method                 )
    assert_equal( File.expand_path( __FILE__ ) , @dep_class.file                   )
    assert_equal( 7                            , @dep_class.line_number            )
    assert_equal( "_deprecated_m1"             , @dep_class.deprecated_method_name )
  end

  def test_records_an_invocation_of_an_instance_method
    dc = @klass.new
    m = dc.m1
    assert_equal( "m1", m )
    assert_equal( 1, @dep_class.invocation_count )
  end

  def test_records_uniq_call_sites
    dc = @klass.new
    3.times { dc.m1 }
    3.times { dc.m1 }
    assert_equal( 6, @dep_class.invocation_count )
    assert_equal( 2, @dep_class.call_site_count )
  end

  def test_has_a_string_representation_of_a_deprecated_instance_method
    assert_equal( "TestDeprecatableDeprecatedMethod::DeprecatableClass#m1 defined at #{File.expand_path(__FILE__)}:7", @dep_class.to_s )
  end

  def test_has_a_string_representation_of_a_deprecated_module_method
    dm = Deprecatable::DeprecatedMethod.new( @module, "m2", __FILE__, 11 )
    assert_equal( "TestDeprecatableDeprecatedMethod::DeprecatableModule.m2 defined at #{File.expand_path(__FILE__)}:11", dm.to_s )
  end
end

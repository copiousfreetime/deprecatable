require "minitest/autorun"
require "deprecatable/deprecated_method"


class TestDeprecatedMethod < MiniTest::Unit::TestCase
  class DeprecatableClass
    def m1; end
  end

  module DeprecatableModule
    def m2; end
  end

  def setup
    @dep_class = Deprecatable::DeprecatedMethod.new( TestDeprecatedMethod::DeprecatableClass, "m1", __FILE__, 7 )
  end

  def test_records_meta_information_about_the_deprecation
    assert_equal( TestDeprecatedMethod::DeprecatableClass , @dep_class.klass                  )
    assert_equal( "m1"                                    , @dep_class.method                 )
    assert_equal( File.expand_path( __FILE__ )            , @dep_class.file                   )
    assert_equal( 7                                       , @dep_class.line_number            )
    assert_equal( "_deprecated_m1"                        , @dep_class.deprecated_method_name )
  end

  def test_has_a_string_representation_of_a_deprecated_instance_method
    assert_equal( "TestDeprecatedMethod::DeprecatableClass#m1 at #{File.expand_path(__FILE__)}:7", @dep_class.to_s )
  end

  def test_has_a_string_representation_of_a_deprecated_module_method
    dm = Deprecatable::DeprecatedMethod.new( TestDeprecatedMethod::DeprecatableModule, "m2", __FILE__, 11 )
    assert_equal( "TestDeprecatedMethod::DeprecatableModule.m2 at #{File.expand_path(__FILE__)}:11", dm.to_s )
  end
end

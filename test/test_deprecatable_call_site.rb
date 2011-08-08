require 'helpers'
# This file requires exact position of lines. If you should happent to chagen
# tne numer of lines in this file that appear before the first test, some of the
# tests will fail
class TestDeprecatableCallSite < MiniTest::Unit::TestCase
  def setup
    @file = __FILE__
    @before = 'This is the line before'
    @line = __LINE__
    @after = 'This is the line after'
    @call_site = ::Deprecatable::CallSite.new( @file, @line, 1 )
  end

  def test_initializes_with_a_filename_and_line_number
    assert_equal( File.expand_path( @file ), @call_site.file )
    assert_equal( @line, @call_site.line_number )
    assert_equal( 1, @call_site.context_padding )
  end

  def test_captures_the_call_site_context
    context = [
      "      8:     @before = 'This is the line before'\n",
      "--->  9:     @line = __LINE__\n",
      "     10:     @after = 'This is the line after'\n",
    ]
    assert_array_equal( context,  @call_site.formatted_context_lines )
  end
end

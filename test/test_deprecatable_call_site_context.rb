# Context line 1
# Context line 2
# Context line 3
# Context line 4


require 'helpers'

# Context line 9
# Context line 10
# Context line 11
# Context line 12
# Context line 13

class TestDeprecatableCallSiteContext < MiniTest::Unit::TestCase
  def setup
    @ctx = Deprecatable::CallSiteContext.new( File.expand_path(__FILE__), 11, 2 )
  end

  def context_lines_for( range, arrow_line )
    width = ("%d" % range.to_a.last).length
    range.map do |x|
      prefix = ( x == arrow_line ) ? "--->" : "    "
      "#{prefix} #{("%d" % x).rjust( width )}: # Context line #{x}\n"
    end
  end

  def test_gets_the_context_from_the_middle_of_a_file
    context_lines = (9..13).map { |x| "# Context line #{x}\n" }
    assert_array_equal( context_lines, @ctx.context_lines )
  end

  def test_properly_formats_the_context_from_the_middle_of_the_file
    formatted_lines = [ ]
    formatted_lines += context_lines_for( (9..13), 11 )
    assert_array_equal( formatted_lines, @ctx.formatted_context_lines )
  end

  def test_properly_formats_the_context_at_the_beginning_of_the_file
    ctx = Deprecatable::CallSiteContext.new( File.expand_path(__FILE__), 2, 2 )
    formatted_lines = [ ]
    formatted_lines += context_lines_for( (1..4), 2 )
    assert_array_equal( formatted_lines, ctx.formatted_context_lines )
  end

  def test_properly_formats_the_context_at_the_end_of_the_file
    ctx = Deprecatable::CallSiteContext.new( File.expand_path(__FILE__), 56, 2 )
    formatted_lines = [ ]
    formatted_lines += context_lines_for( (54..57), 56)
    assert_array_equal( formatted_lines, ctx.formatted_context_lines )
  end
end

# Context line 54
# Context line 55
# Context line 56
# Context line 57

require 'minitest/autorun'
require 'rmthemegen'

class TestRMThemegenBase < Minitest::Test

  def setup
    @generator=RMThemeGen::Base.new
    @filename = @generator.randthemename
  end

  def test_random_name_not_blank
    STDOUT.puts "theme name: " + @generator.randthemename
    refute_empty @generator.randthemename
  end

  def test_random_color_not_blank
    STDOUT.puts "random color: " + @generator.randcolor
    refute_empty @generator.randcolor
  end
  
  def teardown
  end

end 

require 'minitest/autorun'
require 'rmthemegen'


class TestRmthemegen < Minitest::Test
  def setup
    @generator=RMThemeGen::Base.new
    @filename = @generator.randthemename
  end

  def test_random_name_not_blank
    STDOUT.puts @generator.randthemename
    refute_empty @generator.randthemename
  end
  
  def teardown
  end

end 

require 'minitest/autorun'
require 'rmthemegen'


class RmthemegenTests < Test::Unit::TestCase
  def setup
    @generator = RMThemeGen::ThemeGenerator.new
    @filename = @generator.randthemename
  end

  def test_random_names_ok
  end
  
  def teardown
  end

end 

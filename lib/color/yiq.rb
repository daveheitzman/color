# A colour object representing YIQ (NTSC) colour encoding.
class Color::YIQ
  include Color

  class << self 
    # Creates a YIQ colour object from fractional values 0 .. 1.
    #
    #   Color::YIQ.new(0.3, 0.2, 0.1)
    def from_fraction(y = 0, i = 0, q = 0, &block)
      new(y, i, q, 1.0, &block)
    end

    def random
      self.new(rand()*100,rand()*100,rand()*100)
    end 
  end 

  # Creates a YIQ colour object from percentages 0 .. 100.
  #
  #   Color::YIQ.new(10, 20, 30)
  def initialize(y = 0, i = 0, q = 0, radix = 100.0, &block) # :yields self:
    @y, @i, @q = [ y, i, q ].map { |v| Color.normalize(v / radix) }
    block.call if block
  end

  def coerce(other)
    other.to_yiq
  end

  def to_yiq
    self
  end

  def to_lab
    to_rgb.to_lab
  end 
  
  def to_rgb
    # returns the rgb equivalent of this color
    # http://en.wikipedia.org/wiki/YIQ
    r=[1, 0.9563, 0.6210].inject{ |i,sum| sum + i * @y }
    g=[1,-0.2721 , -0.6474].inject{ |i,sum| sum + i * @i }
    b=[1,-1.1070 , -0.6474].inject{ |i,sum| sum +  i * @q }
    Color::RGB.from_fraction(r,g,b)
  end 

  def brightness
    @y
  end
  def to_grayscale
    Color::GrayScale.new(@y)
  end
  alias to_greyscale to_grayscale

  def y
    @y
  end
  def y=(yy)
    @y = Color.normalize(yy)
  end
  def i
    @i
  end
  def i=(ii)
    @i = Color.normalize(ii)
  end
  def q
    @q
  end
  def q=(qq)
    @q = Color.normalize(qq)
  end

  def inspect
    "YIQ [%.2f%%, %.2f%%, %.2f%%]" % [ @y * 100, @i * 100, @q * 100 ]
  end

  def contrast(other_color, options={}) 
    if options[:algorithm]==:delta_e94 
      Color::LAB.delta_e94(self.to_lab,other_rgb.to_lab )
    elsif options[:algorithm]==:delta_e2000 
      Color::LAB.delta_e2000(self.to_lab,other_rgb.to_lab )
    else 
      to_rgb.contrast(other_color.to_rgb, options)
    end 
  end 

  def to_a
    [ y, i, q ]
  end
end

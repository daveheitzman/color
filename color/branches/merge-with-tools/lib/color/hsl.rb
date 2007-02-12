#--
# Colour management with Ruby.
#
# Copyright 2005 Austin Ziegler
#   http://rubyforge.org/ruby-pdf/
#
#   Licensed under a MIT-style licence.
#
# $Id: hsl.rb 153 2007-02-07 02:28:41Z austin $
#++

# An HSL colour object. Internally, the hue (#h), saturation (#s), and
# luminosity/lightness (#l) values are dealt with as fractional values in
# the range 0..1.
class Color::HSL
  class << self
    # Creates an HSL colour object from fractional values 0..1.
    def from_fraction(h = 0.0, s = 0.0, l = 0.0)
      colour = Color::HSL.new
      colour.h = h
      colour.s = s
      colour.l = l
      colour
    end
  end

  # Compares the other colour to this one. The other colour will be
  # converted to HSL before comparison, so the comparison between a HSL
  # colour and a non-HSL colour will be approximate and based on the other
  # colour's #to_hsl conversion. If there is no #to_hsl conversion, this
  # will raise an exception. This will report that two HSL values are
  # equivalent if all component values are within 1e-4 (0.0001) of each
  # other.
  def ==(other)
    other = other.to_hsl
    other.kind_of?(Color::HSL) and
    ((@h - other.h).abs <= 1e-4) and
    ((@s - other.s).abs <= 1e-4) and
    ((@l - other.l).abs <= 1e-4)
  end

  # Creates an HSL colour object from the standard values of degrees and
  # percentages (e.g., 145 deg, 30%, 50%).
  def initialize(h = 0, s = 0, l = 0)
    @h = h / 360.0
    @s = s / 100.0
    @l = l / 100.0
  end

  # Present the colour as an HTML/CSS colour string.
  def html
    to_rgb.html
  end

  # Converting to HSL as adapted from Foley and Van-Dam from
  # http://www.bobpowell.net/RGBHSB.htm.
  #
  # NOTE:
  # * If the colour's luminosity is near zero, the colour is always black.
  # * If the colour's luminosity is near one, the colour is always white.
  # * If the colour's saturation is near zero, the colour is always a shade
  #   of grey and is based only on the luminosity of the colour.
  #
  def to_rgb(ignored = nil)
    return Color::RGB.new if Color.near_zero_or_less?(@l)
    return Color::RGB.new(0xff, 0xff, 0xff) if Color.near_one_or_more?(@l)
    return Color::RGB.new(@l, @l, @l) if Color.near_zero?(@s)

    # Is the value less than 0.5?
    if Color.near_zero_or_less?(@l - 0.5) # (@l - 0.5) < Color::COLOR_EPSILON
      tmp2 = @l * (1.0 + @s.to_f)
    else
      tmp2 = @l + @s - (@l * @s.to_f)
    end
    tmp1 = 2.0 * @l - tmp2

    tmp3  = [ @h + (1.0 / 3.0), @h, @h - (1.0 / 3.0) ]

    rgb = tmp3.map { |hue|
      hue += 1.0 if Color.near_zero_or_less?(hue)
      hue -= 1.0 if Color.near_one_or_more?(hue)

      if ((6.0 * hue) - 1.0) < Color::COLOR_EPSILON
        tmp1 + ((tmp2 - tmp1) * hue * 6.0)
      elsif ((2.0 * hue) - 1.0) < Color::COLOR_EPSILON
        tmp2
      elsif ((3.0 * hue) - 2.0) < Color::COLOR_EPSILON
        tmp1 + (tmp2 - tmp1) * ((2 / 3.0) - hue) * 6.0
      else
        tmp1
      end
    }

     Color::RGB.from_fraction(*rgb)
  end

    # Converts to RGB then YIQ.
  def to_yiq
    to_rgb.to_yiq
  end

    # Converts to RGB then CMYK.
  def to_cmyk
    to_rgb.to_cmyk
  end

    # Returns the luminosity (#l) of the colour.
  def brightness
    @l
  end
  def to_greyscale
    Color::GrayScale.from_fraction(@l)
  end
  alias to_grayscale to_greyscale

  # Returns the hue of the colour in degrees.
  def hue
    (@h * 360.0).round
  end
  # Returns the hue of the colour in the range 0.0 .. 1.0.
  def h
    @h
  end
  # Sets the hue of the colour in degrees. Colour is perceived as a wheel,
  # so values should be set properly even with negative degree values.
  def hue=(hh)
    hh = hh / 360.0

    hh += 1.0 if hh < 0.0
    hh -= 1.0 if hh > 1.0

    @h = Color.normalize(hh)
  end
  # Sets the hue of the colour in the range 0.0 .. 1.0.
  def h=(hh)
    @h = Color.normalize(hh)
  end

  # Returns the percentage of saturation of the colour.
  def saturation
    (@s * 100.0).round
  end
  # Returns the saturation of the colour in the range 0.0 .. 1.0.
  def s
    @s
  end
  # Sets the percentage of saturation of the colour.
  def saturation=(ss)
    @s = Color.normalize(ss / 100.0)
  end
  # Sets the saturation of the colour in the ragne 0.0 .. 1.0.
  def s=(ss)
    @s = Color.normalize(ss)
  end

  # Returns the percentage of luminosity of the colour.
  def luminosity
    (@l * 100.0).round
  end
  alias lightness luminosity
  # Returns the luminosity of the colour in the range 0.0 .. 1.0.
  def l
    @l
  end
  # Sets the percentage of luminosity of the colour.
  def luminosity=(ll)
    @l = Color.normalize(ll / 100.0)
  end
  alias lightness= luminosity=
  # Sets the luminosity of the colour in the ragne 0.0 .. 1.0.
  def l=(ll)
    @l = Color.normalize(ll)
  end

  def to_hsl
    self
  end

  # Mix the mask colour (which will be converted to an HSL colour) with the
  # current colour at the stated mix percentage as a decimal value.
  #
  # NOTE::  This differs from Color::RGB#mix_with.
  def mix_with(color, mix_percent = 0.5)
    color   = color.to_hsl
    _h = ((color.h - self.h) * mix_percent) + self.h
    _s = ((color.s - self.s) * mix_percent) + self.s
    _l = ((color.l - self.l) * mix_percent) + self.l

    self.class.from_fraction(_h, _s, _l)
  end
end
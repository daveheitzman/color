# -*- ruby encoding: utf-8 -*-

# An LAB colour object.
# CIELAB color system  
class Color::LAB
  include Color
  attr_accessor :l, :a, :b 

  def initialize(l,a,b)
    # l should be in the range [0..100.0], however, sometimes it might slightly overflow because of 
    # calculations done in methods creating new LAB objects. The intent is to support slightly overflowed values,
    # accepting them as 100.0, but not anything greater than that, which might indicate an error on the
    # caller's part 
    l=(l*10_000).round.to_f / 10_000 # ruby 1.8.7 does not support l.round(4)
    if !( (0.0..100.0).include?( l ) )
      raise ArgumentError.new("'L' value of a new Lab color must be in the range [0.0..100.0], given was #{l}")
    end 
    @l = l 
    @a = a 
    @b = b 
  end 

  def contrast(other_color, options={})
    # options: :algorithm=><:delta_e94|:delta_e2000>
    # options: :normalize=><true: result is in range [0..1) >
    # e2000 avg 85.82172869559955
    # e94 avg 82.76084360970268
    result=if options[:algorithm]==:delta_e94 
      # to normalize, divide result by 485 
      Color::LAB.delta_e94( self.to_lab, other_color.to_lab )
      if options[:normalize]
        res/485.0
      else      
        res
      end 
    elsif options[:algorithm]==:delta_e2000
      # to normalize, divide result by 283 
      res=Color::LAB.delta_e2000( self.to_lab, other_color.to_lab )
      if options[:normalize]
        res/283.0
      else      
        res
      end 
    else
      Color::LAB.delta_e2000( self.to_lab, other_color.to_lab )
      if options[:normalize]
        res/485.0
      else      
        res
      end 
    end 
  end

  def to_lab
    self 
  end 

  class << self 
    def random
      self.new(rand*100, rand*1000-500, rand*400-200)
    end 

    def rad_to_deg(rad)
      @@_ratio ||= 180 /(Math::PI)
      if rad < 0
        r=rad % -Math::PI
        r = (Math::PI + r)*@@_ratio + 180
      else
        r=rad % Math::PI
        r = r * @@_ratio
      end 
    end 
    
    def deg_to_rad(deg)
      deg = ( (deg % 360) + 360 ) % 360
      if deg >= 180
        Math::PI * (deg - 360) / 180.0
      else 
        Math::PI * deg / 180.0
      end  
    end 

    
    # http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE2000.html
    # www.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf
    def delta_e2000(color_1,color_2) # l1 and l2 should be of type Color::LAB 
      @@tf7 ||= 25**7
      @@twopi ||= Math::PI * 2 
      @@halfpi ||= Math::PI / 2
      @@thirty ||=  Math::PI * 30/180.0 
      @@six ||= Math::PI * 6 / 180.0
      @@sixty_three ||=  Math::PI * 63.0/180
      @@two_seventy_five ||= (275.0 - 360) * Math::PI 

      k_C = k_H = k_L = 1
      l_1, a_1, b_1 = color_1.l, color_1.a, color_1.b
      l_2, a_2, b_2 = color_2.l, color_2.a, color_2.b
      l_bar_prime = (l_1 + l_2) / 2 
      c_1 = Math.sqrt((a_1 ** 2) + (b_1 ** 2))
      c_2 = Math.sqrt((a_2 ** 2) + (b_2 ** 2))
      c_bar = (c_1 + c_2)/2.0

      c_bar7=c_bar**7.0
      g = 0.5*(1-Math.sqrt( c_bar7.to_f/( c_bar7 + @@tf7 ) ) ) 
      a1_prime = a_1 * (1 + g)
      a2_prime = a_2 * (1 + g)
      c1_prime = Math.sqrt(a1_prime**2 + b_1**2 )
      c2_prime = Math.sqrt(a2_prime**2 + b_2**2 )
      c_bar_prime = (c1_prime + c2_prime)/2.0
      h1_prime = 
      if a1_prime == 0 && b_1 == 0
        0.0 
      else
        Math.atan2(b_1,a1_prime) 
      end 
      h2_prime =
      if a2_prime == 0 && b_2 == 0
        0.0 
      else
        Math.atan2(b_2,a2_prime)
      end 
      h_diff = (h1_prime - h2_prime).abs
      h_bar_prime = h_diff > Math::PI ? (h2_prime + h1_prime + @@twopi) / 2 : ( h2_prime + h1_prime ) / 2
      
      t = 1 - 0.17*Math.cos(h_bar_prime - @@thirty) + 
        0.24 * Math.cos( 2*h_bar_prime ) + 
        0.32 * Math.cos(3*h_bar_prime + @@six) - 
        0.2*Math.cos(4*h_bar_prime - @@sixty_three )

      delta_h_prime=
        if (c_1 * c_2) == 0 
          0
        elsif h_diff <= Math::PI
          h2_prime - h1_prime 
        elsif (h2_prime-h1_prime) > Math::PI # && h2_prime > h1_prime
          h2_prime - h1_prime - @@twopi
        elsif (h2_prime-h1_prime) <= Math::PI #&& h2_prime <= h1_prime
          h2_prime - h1_prime + @@twopi
        end
      delta_l_prime = l_2 - l_1
      delta_c_prime = c2_prime - c1_prime
      delta_H_prime = ( 2*Math.sqrt(c1_prime * c2_prime)*Math.sin(delta_h_prime / 2.0) )
      s_L = 1 + (0.015*(l_bar_prime-50)**2)/( Math.sqrt(20+(l_bar_prime-50.0)**2) )
      s_C = 1 + 0.045 * c_bar_prime
      s_H = 1 + 0.015 * c_bar_prime * t
      delta_theta = 30 * ( Math.exp( -( ( rad_to_deg(h_bar_prime) - 275.0 )/25.0)**2 ) )
      cbp7 = c_bar_prime**7
      r_C =2 * Math.sqrt( cbp7 / (cbp7 + @@tf7 ) ) 
      r_T = r_C*-Math.sin(2* deg_to_rad( delta_theta) )
      Math.sqrt( (delta_l_prime / (k_L * s_L ) )**2 +
                 (delta_c_prime / ( k_C*s_C ) )**2 + 
                 (delta_H_prime / (k_H*s_H) )**2 + 
                 r_T*(delta_c_prime/(k_C*s_C))*(delta_H_prime/( k_H*s_H) )) 
    end 

    # The Delta E (CIE94) algorithm
    # http://en.wikipedia.org/wiki/Color_difference#CIE94
    #
    # There is a newer version, CIEDE2000, that uses slightly more complicated
    # math, but addresses "the perceptual uniformity issue" left lingering by
    # the CIE94 algorithm. color_1 and color_2 are both L*a*b* hashes,
    # rendered by #to_lab.
    #
    # Since our source is treated as sRGB, we use the "graphic arts" presets
    # for k_L, k_1, and k_2
    #
    # The calculations go through LCH(ab). (?)
    #
    # See also http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
    #
    # NOTE: This should be moved to Color::Lab.
    def delta_e94(color_1, color_2, weighting_type = :graphic_arts)
      case weighting_type
      when :graphic_arts
        k_1 = 0.045
        k_2 = 0.015
        k_L = 1
      when :textiles
        k_1 = 0.048
        k_2 = 0.014
        k_L = 2
      else
        raise ArgumentError, "Unsupported weighting type #{weighting_type}."
      end

      # delta_E = Math.sqrt(
      #   ((delta_L / (k_L * s_L)) ** 2) +
      #   ((delta_C / (k_C * s_C)) ** 2) +
      #   ((delta_H / (k_H * s_H)) ** 2)
      # )
      #
      # Under some circumstances in real computers, delta_H could be an
      # imaginary number (it's a square root value), so we're going to treat
      # this as:
      #
      # delta_E = Math.sqrt(
      #   ((delta_L / (k_L * s_L)) ** 2) +
      #   ((delta_C / (k_C * s_C)) ** 2) +
      #   (delta_H2 / ((k_H * s_H) ** 2)))
      # )
      #
      # And not perform the square root when calculating delta_H2.

      k_C = k_H = 1

      l_1, a_1, b_1 = color_1.l, color_1.a, color_1.b 
      l_2, a_2, b_2 = color_2.l, color_2.a, color_2.b

      delta_a = a_1 - a_2
      delta_b = b_1 - b_2

      c_1 = Math.sqrt((a_1 ** 2) + (b_1 ** 2))
      c_2 = Math.sqrt((a_2 ** 2) + (b_2 ** 2))

      delta_L = l_1 - l_2
      delta_C = c_1 - c_2

      delta_H2 = (delta_a ** 2) + (delta_b ** 2) - (delta_C ** 2)

      s_L = 1
      s_C = 1 + k_1 * c_1
      s_H = 1 + k_2 * c_1

      composite_L = (delta_L / (k_L * s_L)) ** 2
      composite_C = (delta_C / (k_C * s_C)) ** 2
      composite_H = delta_H2 / ((k_H * s_H) ** 2)
      Math.sqrt(composite_L + composite_C + composite_H)
    end
  end 

end

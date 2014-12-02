# require 'xmlsimple'
# require 'color'
# require File.dirname(__FILE__)+"/token_list"
# require File.dirname(__FILE__)+'/rgb_contrast_methods'
require 'rmthemegen'

l = RMThemeGen::Base.new
max=0
min=10000000
runs = 1_000_000
runs.times do |t|
  c1=Color::RGB.new rand*256,rand*256,rand*256
  c2=Color::RGB.new rand*256,rand*256,rand*256
  
  # puts "#{c1.to_s} , #{c2.to_s}, #{c2.contrast(c1,:delta_e2000)}"
  cont=c2.contrast(c1,:delta_e2000)
  max=cont if cont > max 
  min=cont if cont < min 
end 

puts "Lab CIE contrast. #{runs} tested. Contrast: max=#{max}, min=#{min} "
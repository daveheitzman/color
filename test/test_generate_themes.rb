#! /usr/bin/ruby 
#**********************************************************************
#*                                                                    *
#*  RmThemeGen - a ruby script to create random, usable themes for    *
#*  text editors. Currently supports RubyMine 3.X.X                   *
#*                                                                    *
#*  By David Heitzman, 2011                                           *
#*                                                                    *
#**********************************************************************

#this is a version of the software that should work with ruby 1.8.7
#originally it was written and tested for ruby 1.9.2


require File.dirname(__FILE__)+'./lib/rmthemegen/rmthemegen_187'
require File.dirname(__FILE__)+'./lib/rmthemegen/rmthemegen_187_textmate'
puts "TEST TEST TEST"
puts    
puts "  Mac:  Copy xml files to ~/Library/Preferences/RubyMine/color. You must restart RubyMine on the Mac, then look for new color schemes. "
puts

=begin
c=Color::RGB.new(0,0,0)
1000.times do 
puts c.next_gaussian(0.50 ) 
end 
Kernel.exit
=end

 
l = RMThemeGen::ThemeGenerator.new

50.times do 
#  puts l.make_theme_file(:outputdir => ENV["PWD"],:bg_color_style => 0 ) 
#  puts l.make_theme_file(ENV["PWD"],0,[{:r=>0.0,:g=>0.0},{:r=>1.0,:g=>0.0,:b=>0.0}]) 
  puts l.make_theme_file(ENV["PWD"],0,nil,nil) 
  puts l.to_textmate
#  puts l.make_theme_file(:outputdir => ENV["PWD"],:bg_color_style => 2 ) 
  end
puts "testing to_css"
puts l.to_css
puts "testing themename"
puts l.themename
puts

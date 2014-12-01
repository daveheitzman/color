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

require 'rubygems'
require 'color'
require 'xmlsimple'
require File.dirname(__FILE__)+"/token_list"
require File.dirname(__FILE__)+'/rgb_contrast_methods'


module RMThemeGen
  
  class ThemeGenerator < Base
    
      def to_css
      #fout = File.new("index.html", "w+")
      s = ' <style type="text/css"> '
      s+= "#"+ @xmlout[:scheme][0][:name].to_s  
      s+=" { background-color: \##{@backgroundcolor.to_s}; } "
        @xmlout[:scheme][0][:attributes][0][:option].each do |o|
          if @@tokens_for_css.include? o[:name]
            s+= "#"+ @xmlout[:scheme][0][:name].to_s 
            s+= " .#{o[:name]} {color: \##{o[:value][0][:option][0][:value]};"
            #fonttype = 0 #bold: 1,  #italic: 2, bold & italic: 3
            if o[:value][0][:option][3][:value] == '0'
              #neither bold nor italic
              s+= ""
            elsif o[:value][0][:option][3][:value] == '1'
              s+= "font-weight:bold;"
            elsif o[:value][0][:option][3][:value] == '2'
              s+= "font-style:italic;"
            elsif o[:value][0][:option][3][:value] == '2' #bold and italic
              s+= "font-weight:bold;font-style: italic;"
            end #if
        s+="} "  
          end #if 
        end 
  #these options are all for background values so far (caret row color and selection background)
  # so we will treat them all that way for now (see line 41: s+= " .#{o[:name]} {background-color: \##{o[:value]};} "

        @xmlout[:scheme][0][:colors][0][:option].each do |o|
          if @@tokens_for_css.include? o[:name]
            s+= "#"+ @xmlout[:scheme][0][:name].to_s 
#            puts o.inspect
            s+= " .#{o[:name]} {background-color: \##{o[:value]};} "
          end #if 
        end 
          
      s += ' </style> ' 
    #  y="<div id='#{@xmlout[:scheme][0][:name].to_s}'>"
    #    @xmlout[:scheme][0][:attributes][0][:option].each do |o|
    #      if @@tokens_for_css.include? o[:name]
    #        y+= "<span class='#{o[:name]}'>"+ o[:name]+"</span>" 
    #      end #if 
    #    end
      return s
      end
  end #class ThemeGenerator < Base
end #module RMThemeGen

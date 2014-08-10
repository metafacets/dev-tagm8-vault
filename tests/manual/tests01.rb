require 'pp'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tags01.rb'
Tag.add_tag(:mouse,:animal)
puts "1. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:cat, :mammal)
puts "2. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:dog, :mammal)
puts "3. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:animal, :life)
puts "4. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:life, :dog)
puts "5. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:mammal, :animal)
puts "6. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:fish, :animal)
Tag.add_tag(:carp, :fish)
Tag.add_tag(:carp, :food)
Tag.add_tag(:carpette, :carp)
Tag.add_tag(:herring, :fish)
Tag.add_tag(:insect, :animal)
puts "7. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:mouse).get_descendents}"
puts "descendents= #{Tag.get_tag(:mammal).get_descendents}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"
puts "ancestors= #{Tag.get_tag(:carpette).get_ancestors}"
puts "depth= #{Tag.get_tag(:carpette).get_depth(Tag.get_tag(:fish),Tag.get_tag(:fish).get_descendents)}"
Tag.delete_tag(:mammal)
puts "8. Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"

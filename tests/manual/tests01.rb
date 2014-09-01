require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\debug.rb'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\tag.rb'

Debug.new(tags:[:test]) # comment out to turn off

Tag.dag_fix
Tag.add_tag(:mouse,:animal)
Debug.show(note:1,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Tag.add_tags([:cat, :dog], :mammal)
Debug.show(note:2,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Tag.add_tag(:animal, :life)
Debug.show(note:3,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Tag.add_tag(:life, :dog)
Debug.show(note:4,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Tag.add_tag(:mammal, :animal)
Debug.show(note:5,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Tag.add_tags([:fish, :insect], :animal)
Tag.add_tags([:carp, :herring], :fish)
Tag.add_tag(:carp, :food)
Tag.add_tag(:carpette, :carp)
Debug.show(note:6,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Debug.show(tags:[:test],level:4,vars:[['descendents',Tag.get_tag(:mouse).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['descendents',Tag.get_tag(:mammal).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['descendents',Tag.get_tag(:animal).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['ancestors',Tag.get_tag(:carpette).get_ancestors]])
Debug.show(tags:[:test],level:4,vars:[['depth',Tag.get_tag(:carpette).get_depth(Tag.get_tag(:fish),Tag.get_tag(:fish).get_descendents)]])
Tag.delete_tag(:mammal)
Debug.show(note:7,tags:[:test],vars:[['tags',Tag.get_tags],['roots',Tag.get_roots],['folks',Tag.get_folksonomy]])
Debug.show(tags:[:test],level:4,vars:[['descendents',Tag.get_tag(:animal).get_descendents]])

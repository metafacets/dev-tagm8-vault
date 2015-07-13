require_relative '../../src/app/debug'
require_relative '../../src/app/tag'

Tagm8Db.open('tagm8-test')
Tagm8Db.wipe

Debug.new(tags:[:test]) # comment out to turn off

tax = Taxonomy.new
tax.set_dag('fix')
tax.add_tag(:mouse,:animal)
Debug.show(note:1,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
tax.add_tags([:cat, :dog], :mammal)
Debug.show(note:2,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
tax.add_tag(:animal, :life)
Debug.show(note:3,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
tax.add_tag(:life, :dog)
Debug.show(note:4,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
tax.add_tag(:mammal, :animal)
Debug.show(note:5,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
tax.add_tags([:fish, :insect], :animal)
tax.add_tags([:carp, :herring], :fish)
tax.add_tag(:carp, :food)
tax.add_tag(:carpette, :carp)
Debug.show(note:6,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
Debug.show(tags:[:test],level:4,vars:[['descendents',tax.get_tag_by_name(:mouse).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['descendents',tax.get_tag_by_name(:mammal).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['descendents',tax.get_tag_by_name(:animal).get_descendents]])
Debug.show(tags:[:test],level:4,vars:[['ancestors',tax.get_tag_by_name(:carpette).get_ancestors]])
Debug.show(tags:[:test],level:4,vars:[['depth',tax.get_tag_by_name(:carpette).get_depth(tax.get_tag_by_name(:fish),tax.get_tag_by_name(:fish).get_descendents)]])
tax.delete_tag(:mammal)
Debug.show(note:7,tags:[:test],vars:[['tags',tax.tags],['roots',tax.roots],['folks',tax.folksonomy]])
Debug.show(tags:[:test],level:4,vars:[['descendents',tax.get_tag_by_name(:animal).get_descendents]])

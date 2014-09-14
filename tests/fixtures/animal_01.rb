module AnimalTaxonomy
  def animal_taxonomy(instantiate=true)
    Tag.empty
    Tag.dag_fix
    if instantiate
      Tag.instantiate(':mouse<:animal')
      Tag.instantiate('[:cat,:dog]<:mammal')
      Tag.instantiate(':animal<:life')
      Tag.instantiate(':life<:dog')
      Tag.instantiate(':mammal<:animal')
#      Tag.instantiate('[[:carp,:herring]<:fish,:insect]<:animal')
      Tag.instantiate('[:carp,:herring]<:fish')
      Tag.instantiate('[:fish,:insect]<:animal')
      Tag.instantiate(':carpette<:carp<:food')
    else
      Tag.add_tag(:mouse,:animal)
      Tag.add_tags([:cat, :dog], :mammal)
      Tag.add_tag(:animal, :life)
      Tag.add_tag(:life, :dog)
      Tag.add_tag(:mammal, :animal)
      Tag.add_tags([:fish, :insect], :animal)
      Tag.add_tags([:carp, :herring], :fish)
      Tag.add_tag(:carp, :food)
      Tag.add_tag(:carpette, :carp)
    end
    puts "deleting ;mammal"
    Tag.delete_tag(:mammal)
  end
end

module AnimalTaxonomy
  def animal_taxonomy(instantiate=true)
    tax = Taxonomy.new
    tax.dag_fix
    if instantiate
      tax.instantiate(':mouse<:animal')
      tax.instantiate('[:cat,:dog]<:mammal')
      tax.instantiate(':animal<:life')
      tax.instantiate(':life<:dog')
      tax.instantiate(':mammal<:animal')
#      tax.instantiate('[[:carp,:herring]<:fish,:insect]<:animal')
      tax.instantiate('[:carp,:herring]<:fish')
      tax.instantiate('[:fish,:insect]<:animal')
      tax.instantiate(':carpette<:carp<:food')
    else
      tax.add_tag(:mouse,:animal)
      tax.add_tags([:cat, :dog], :mammal)
      tax.add_tag(:animal, :life)
      tax.add_tag(:life, :dog)
      tax.add_tag(:mammal, :animal)
      tax.add_tags([:fish, :insect], :animal)
      tax.add_tags([:carp, :herring], :fish)
      tax.add_tag(:carp, :food)
      tax.add_tag(:carpette, :carp)
    end
    tax.delete_tag(:mammal)
    tax
  end
end

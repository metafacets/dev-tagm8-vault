module AnimalTaxonomy
  def animal_taxonomy(instantiate=true)
    tax = Taxonomy.new
    tax.set_dag('fix')
    if instantiate
      tax.instantiate(':mouse<:animal')
      tax.instantiate('[:cat,:dog]<:mammal')
      tax.instantiate(':animal<:life')
      tax.instantiate(':life<:dog')
      tax.instantiate(':mammal<:animal')
      #tax.instantiate('[[:carp,:herring]<:fish,:insect]<:animal')
      tax.instantiate('[:carp,:herring]<:fish')
      tax.instantiate('[:fish,:insect]<:animal')
      tax.instantiate(':carpette<:carp<:food')
    else
#      puts "**tag_spec: add_tag(:mouse,:animal)"
      tax.add_tag(:mouse,:animal)
#      puts "**tag_spec: add_tag([:cat, :dog], :mammal)"
      tax.add_tags([:cat, :dog], :mammal)
#      puts "**tag_spec: add_tag(:animal, :life)"
      tax.add_tag(:animal, :life)
#      puts "**tag_spec: add_tag(:life, :dog)"
      tax.add_tag(:life, :dog)
#      puts "**tag_spec: add_tag(:mammal, :animal)"
      tax.add_tag(:mammal, :animal)
#      puts "**tag_spec: add_tag([:fish, :insect], :animal)"
      tax.add_tags([:fish, :insect], :animal)
#      puts "**tag_spec: add_tag([:carp, :herring], :fish)"
      tax.add_tags([:carp, :herring], :fish)
#      puts "**tag_spec: add_tag(:carp, :food)"
      tax.add_tag(:carp, :food)
#      puts "tag_spec: add_tag(:carpette, :carp)"
      tax.add_tag(:carpette, :carp)
    end
    tax.delete_tag(:mammal)
    tax
  end
end

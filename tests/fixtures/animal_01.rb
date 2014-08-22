module AnimalTaxonomy
  def instantiate_animal_taxonomy
    Tag.empty
    Tag.add_tag(:mouse,:animal)
    Tag.add_tags([:cat, :dog], :mammal)
    Tag.add_tag(:animal, :life)
    Tag.add_tag(:life, :dog)
    Tag.add_tag(:mammal, :animal)
    Tag.add_tags([:fish, :insect], :animal)
    Tag.add_tags([:carp, :herring], :fish)
    Tag.add_tag(:carp, :food)
    Tag.add_tag(:carpette, :carp)
    Tag.delete_tag(:mammal)
    puts "8. Tags = #{Tag.get_tags}"
  end
end

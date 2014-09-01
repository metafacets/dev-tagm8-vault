require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\tag.rb'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tests\fixtures\animal_01.rb'

describe Tag do
  include AnimalTaxonomy
  context ':animal > :mouse, :car' do
    before(:all) do
      Tag.empty
      Tag.add_tag(:mouse, :animal)
      Tag.add_tag(:car)
      @animal = Tag.get_tag(:animal)
      @mouse = Tag.get_tag(:mouse)
      @car = Tag.get_tag(:car)
      @taxonomy = Tag.get_tags
    end
    it 'taxonomy has 3 tags' do expect(@taxonomy.size).to eq(3) end
    it 'car has no children' do expect(@car).to_not have_child end
    it 'car has no parents' do expect(@car).to_not have_parent end
    it 'car is folk' do expect(@car).to be_folk end
    it 'car is not root' do expect(@car).to_not be_root end
    it 'animal has child' do expect(@animal).to have_child end
    it 'animal has no parents' do expect(@animal).to_not have_parent end
    it 'animal is not folk' do expect(@animal).to_not be_folk end
    it 'animal is root' do expect(@animal).to be_root end
    it 'mouse has no children' do expect(@mouse).to_not have_child end
    it 'mouse has parent' do expect(@mouse).to have_parent end
    it 'mouse is not folk' do expect(@mouse).to_not be_folk end
    it 'mouse is not root' do expect(@mouse).to_not be_root end
  end
  context 'folksonomy' do
    before(:all) do
      instantiate_animal_taxonomy
      all_folks = Tag.get_tags.values.select {|tag| tag.folk?}
      @omitted_folks = (all_folks-Tag.get_folksonomy)
      @non_folks = (Tag.get_folksonomy-all_folks)
      @taxonomy = Tag.get_tags
    end
    it 'taxonomy has 11 tags' do expect(@taxonomy.size).to eq(11) end
    it 'includes all folks' do expect(@omitted_folks).to be_empty end
    it 'includes only folks' do expect(@non_folks).to be_empty end
  end
  context 'roots' do
    before(:all) do
      instantiate_animal_taxonomy
      all_roots = Tag.get_tags.values.select {|tag| tag.root?}
      @omitted_roots = (all_roots-Tag.get_roots)
      @non_roots = (Tag.get_roots-all_roots)
      @taxonomy = Tag.get_tags
    end
    it 'taxonomy has 11 tags' do expect(@taxonomy.size).to eq(11) end
    it 'includes all roots' do expect(@omitted_roots).to be_empty end
    it 'includes only roots' do expect(@non_roots).to be_empty end
  end
  context 'instance methods' do
    Tag.empty
    subject {Tag.new(:my_tag)}
    methods = [:name,:children,:has_child?,:add_children,:delete_child,:register_child,:parents,:has_parent?,:add_parents,:delete_parent,:register_parent]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
    it ':name ok' do expect(subject.name).to eq(:my_tag) end
  end
  context 'prevent recursion (:a <-+-> :a)' do
    [:dag_fix,:dag_prevent].each do |context|
      context context do
        Tag.empty
        Tag.send(context)
        Tag.add_tag(:animal,:animal)
        taxonomy = Tag.get_tags
        animal = Tag.get_tag(:animal)
        it 'taxonomy has 1 tag' do expect(taxonomy.size).to eq(1) end
        it 'animal has no parents' do expect(animal).to_not have_parent end
        it 'animal has no children' do expect(animal).to_not have_child end
        it 'animal is not root' do expect(animal).to_not be_root end
        it 'animal is folk' do expect(animal).to be_folk end
      end
    end
  end
  context 'prevent reflection (:a -> :b -+-> :a)' do
    context ':dag_fix (:a -x-> :b -> :a)' do
      Tag.empty
      Tag.dag_fix
      Tag.add_tag(:mammal,:animal)
      Tag.add_tag(:animal,:mammal)
      taxonomy = Tag.get_tags
      roots = Tag.get_roots
      folks = Tag.get_folksonomy
      animal = Tag.get_tag(:animal)
      mammal = Tag.get_tag(:mammal)
      it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
      it 'roots has 1 tag' do expect(roots.size).to eq(1) end
      it 'folks is empty' do expect(folks.size).to eq(0) end
      it 'mammal has no parent' do expect(mammal).to_not have_parent end
      it 'mammal has child' do expect(mammal).to have_child end
      it 'animal has parent' do expect(animal).to have_parent end
      it 'animal has no children' do expect(animal).to_not have_child end
      it 'mammal is root' do expect(mammal).to be_root end
    end
    context ':dag_prevent (:a -> :b -x-> :a)' do
      Tag.empty
      Tag.dag_prevent
      Tag.add_tag(:mammal,:animal)
      Tag.add_tag(:animal,:mammal)
      taxonomy = Tag.get_tags
      roots = Tag.get_roots
      folks = Tag.get_folksonomy
      animal = Tag.get_tag(:animal)
      mammal = Tag.get_tag(:mammal)
      it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
      it 'roots has 1 tag' do expect(roots.size).to eq(1) end
      it 'folks is empty' do expect(folks.size).to eq(0) end
      it 'animal has no parent' do expect(animal).to_not have_parent end
      it 'animal has child' do expect(animal).to have_child end
      it 'mammal has parent' do expect(mammal).to have_parent end
      it 'mammal has no children' do expect(mammal).to_not have_child end
      it 'animal is root' do expect(animal).to be_root end
    end
  end
  context 'prevent looping (:a -> :b -> :c -+-> :a)' do
    context ':dag_fix (:a -x-> :b -> :c -> :a)' do
      Tag.empty
      Tag.dag_fix
      Tag.add_tag(:mammal,:animal)
      Tag.add_tag(:mouse,:mammal)
      Tag.add_tag(:animal,:mouse)
      taxonomy = Tag.get_tags
      roots = Tag.get_roots
      folks = Tag.get_folksonomy
      animal = Tag.get_tag(:animal)
      mammal = Tag.get_tag(:mammal)
      mouse = Tag.get_tag(:mouse)
      it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
      it 'roots has 1 tag' do expect(roots.size).to eq(1) end
      it 'folks is empty' do expect(folks.size).to eq(0) end
      it 'mouse has no parent' do expect(mouse).to_not have_parent end
      it 'mouse has child' do expect(mouse).to have_child end
      it 'animal has parent' do expect(animal).to have_parent end
      it 'animal has child' do expect(animal).to have_child end
      it 'mammal has parent' do expect(mammal).to have_parent end
      it 'mammal has no child' do expect(mammal).to_not have_child end
      it 'mouse is root' do expect(mouse).to be_root end
    end
    context ':dag_prevent (:a -> :b -> :c -x-> :a)' do
      Tag.empty
      Tag.dag_prevent
      Tag.add_tag(:mammal,:animal)
      Tag.add_tag(:mouse,:mammal)
      Tag.add_tag(:animal,:mouse)
      taxonomy = Tag.get_tags
      roots = Tag.get_roots
      folks = Tag.get_folksonomy
      animal = Tag.get_tag(:animal)
      mammal = Tag.get_tag(:mammal)
      mouse = Tag.get_tag(:mouse)
      it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
      it 'roots has 1 tag' do expect(roots.size).to eq(1) end
      it 'folks is empty' do expect(folks.size).to eq(0) end
      it 'animal has no parent' do expect(animal).to_not have_parent end
      it 'animal has child' do expect(animal).to have_child end
      it 'mammal has parent' do expect(mammal).to have_parent end
      it 'mammal has child' do expect(mammal).to have_child end
      it 'mouse has parent' do expect(mouse).to have_parent end
      it 'mouse has no child' do expect(mouse).to_not have_child end
      it 'animal is root' do expect(animal).to be_root end
    end
  end
end
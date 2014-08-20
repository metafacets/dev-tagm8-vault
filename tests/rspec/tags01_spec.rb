require 'rspec'
#require 'rspec-its'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tag.rb'

describe Tag do
  context ':animal > :mouse, :car' do
    before(:all) do
      Tag.empty
      Tag.add_tag(:mouse, :animal)
      Tag.add_tag(:car)
      @animal = Tag.get_tag(:animal)
      @mouse = Tag.get_tag(:mouse)
      @car = Tag.get_tag(:car)
    end
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
      # set-up test data
      all_folks = Tag.get_tags.values.select {|tag| tag.folk?}
      @omitted_folks = (all_folks-Tag.get_folksonomy)
      @non_folks = (Tag.get_folksonomy-all_folks)
    end
    it 'includes all folks' do expect(@omitted_folks).to be_empty end
    it 'includes only folks' do expect(@non_folks).to be_empty end
  end
  context 'roots' do
    before(:all) do
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
      # set-up test data
      all_roots = Tag.get_tags.values.select {|tag| tag.root?}
      @omitted_roots = (all_roots-Tag.get_roots)
      @non_roots = (Tag.get_roots-all_roots)
    end
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
end
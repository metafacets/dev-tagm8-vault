require 'rspec'
#require 'rspec-its'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tags01.rb'

describe Tag do
  context 'childless orphan root and folk' do
    before(:all) do
      Tag.empty
      Tag.add_tag(:mouse, :animal)
      Tag.add_tag(:car)
      @animal = Tag.get_tag(:animal)
      @mouse = Tag.get_tag(:mouse)
      @car = Tag.get_tag(:car)
    end
    it 'car is childless' do
      puts "car=#{@car}"
      @car.should be_childless
    end
    it 'car is orphan' do
      @car.should be_orphan
    end
    it 'car is childless_orphan or folk' do
      @car.should be_childless_orphan
      @car.should be_folk
    end
    it 'animal is not childless' do
      @animal.should_not be_childless
    end
    it 'animal has child' do
      @animal.should be_has_child
    end
    it 'animal is not childless orphan or folk' do
      @animal.should_not be_childless_orphan
      @animal.should_not be_folk
    end
    it 'animal is parent_orphan or root' do
      @animal.should be_parent_orphan
      @animal.should be_root
    end
    it 'mouse is not orphan' do
      @mouse.should_not be_orphan
    end
    it 'mouse has parent' do
      @mouse.should be_has_parent
    end
    it 'mouse is not childless orphan or folk' do
      @mouse.should_not be_childless_orphan
      @mouse.should_not be_folk
    end
    it 'mouse is not parent_orphan or root' do
      @mouse.should_not be_parent_orphan
      @mouse.should_not be_root
    end
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
      @all_childless_orphans = Tag.get_tags.values.select {|tag| tag.childless_orphan?}
    end
    it 'includes all folks' do
      (@all_childless_orphans-Tag.get_folksonomy).should be_empty
    end
    it 'includes only folks' do
      (Tag.get_folksonomy-@all_childless_orphans).should be_empty
    end
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
      @all_roots = Tag.get_tags.values.select {|tag| tag.root?}
    end
    it 'includes all roots' do
      (@all_roots-Tag.get_roots).should be_empty
    end
    it 'includes only roots' do
      (Tag.get_roots-@all_roots).should be_empty
    end
  end
  context 'instance methods' do
    Tag.empty
    subject {Tag.new(:my_tag)}
    it ':name' do should respond_to(:name) end
    it ':children' do should respond_to(:children) end
    it ':has_child?' do should respond_to(:has_child?) end
    it ':add children' do should respond_to(:add_children) end
    it ':delete_child' do should respond_to(:delete_child) end
    it ':register_child' do should respond_to(:register_child) end
    it ':parents' do should respond_to(:parents) end
    it ':has_parent?' do should respond_to(:has_parent?) end
    it ':add_parents' do should respond_to(:add_parents) end
    it ':delete_parent' do should respond_to(:delete_parent) end
    it ':register_parent' do should respond_to(:register_parent) end
    #its(:name){should eq(':my_tag')}
  end
  context 'instantiation' do
    before(:all) do
      Tag.empty
      @tag = Tag.new(:mammal)
    end
    it 'initialises' do
      @tag.should be_an_instance_of Tag
    end
    it 'has supplied name' do
      @tag.name.should == :mammal
    end
  end

end
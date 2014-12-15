require 'rspec'
require_relative '../../src/app/tag_2_odm-high'
require_relative '../../tests/fixtures/animal_01'
include AnimalTaxonomy


describe 'Taxonomy' do
  context 'empty' do
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    [:has_tag?, :has_root?, :has_folksonomy?].each do |method|
      result = tax.send(method)
      it "#{method} is false" do expect(result).to be_falsey end
    end
  end
  context 'add_tag(:a)' do
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    tax.add_tag(:a)
    has_tag = tax.has_tag?
    has_root = tax.has_root?
    has_folk = tax.has_folksonomy?
    it ':has_tag? is true' do expect(has_tag).to be_truthy end
    it ':has_folk? is true' do expect(has_folk).to be_truthy end
    it ':has_root? is false' do expect(has_root).to be_falsey end
  end
  context 'add_tag(:a,:b)' do
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    tax.add_tag(:a,:b)
    has_tag = tax.has_tag?
    has_root = tax.has_root?
    has_folk = tax.has_folksonomy?
    it ':has_tag? is true' do expect(has_tag).to be_truthy end
    it ':has_folk? is false' do expect(has_folk).to be_falsey end
    it ':has_root? is true' do expect(has_root).to be_truthy end
  end
  context ':animal > :mouse, :car' do
    before(:all) do
      tax = Taxonomy.new
      tax.add_tag(:mouse, :animal)
      tax.add_tag(:car)
      @animal = tax.get_tag_by_name(:animal)
      @mouse = tax.get_tag_by_name(:mouse)
      @car = tax.get_tag_by_name(:car)
      @size = tax.tag_count
    end
    it 'taxonomy has 3 tags' do expect(@size).to eq(3) end
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
  context 'tag, root and folksonomy counts' do
    before(:all) do
      MongoMapper.connection.drop_database('tagm8')
      @tax = animal_taxonomy(false)
    end
    it 'taxonomy has 11 tags' do expect(@tax.tag_count).to eq(11) end
    it 'taxonomy has no folks' do expect(@tax.folksonomy_count).to eq(0) end
    it 'taxonomy has 2 roots' do expect(@tax.root_count).to eq(2) end
  end
end
require 'rspec'
require_relative '../../src/app/tag'
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
    it ':has_root? is true' do expect(has_root).to be_falsey end
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
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    puts "tag_spec: add_tag(:mouse, :animal)"
    tax.add_tag(:mouse, :animal)
    puts "tag_spec: add_tag(:car)"
    tax.add_tag(:car)
    animal = tax.get_tag_by_name(:animal)
    mouse = tax.get_tag_by_name(:mouse)
    car = tax.get_tag_by_name(:car)
    puts "tag-spec.48: animal=#{animal}, mouse=#{mouse}, car.has_child?=#{car.has_child?}"
    size = tax.tag_count
    it 'taxonomy has 3 tags' do expect(size).to eq(3) end
    it 'car has no children' do expect(car).to_not have_child end
    it 'car has no parents' do expect(car.has_child?).to_not have_parent end
    it 'car is folk' do expect(car).to be_folk end
    it 'car is not root' do expect(car).to_not be_root end
    it 'animal has child' do expect(animal).to have_child end
    it 'animal has no parents' do expect(animal).to_not have_parent end
    it 'animal is not folk' do expect(animal).to_not be_folk end
    it 'animal is root' do expect(animal).to be_root end
    it 'mouse has no children' do expect(mouse).to_not have_child end
    it 'mouse has parent' do expect(mouse).to have_parent end
    it 'mouse is not folk' do expect(mouse).to_not be_folk end
    it 'mouse is not root' do expect(mouse).to_not be_root end
  end
  context 'tag, root and folksonomy counts' do
    MongoMapper.connection.drop_database('tagm8')
    tax = animal_taxonomy(false)
    it 'taxonomy has 11 tags' do expect(tax.tag_count).to eq(11) end
    it 'taxonomy has no folks' do expect(tax.folksonomy_count).to eq(0) end
    it 'taxonomy has 2 roots' do expect(tax.root_count).to eq(2) end
  end
  context 'instance methods' do
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    subject {tax.get_lazy_tag(:my_tag)}
    methods = [:name,:children,:has_child?,:add_children,:delete_child,:parents,:has_parent?,:add_parents,:delete_parent]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
    it ':name ok' do expect(subject.name).to eq(:my_tag.to_s) end
  end
  describe 'deletion integrity' do
    describe 'parent/child links' do
      describe ':b -x-> :a' do
        describe 'before' do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':a is root' do expect(a).to be_root end
        end
        describe :delete_child do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          puts "tag-spec.delete_child: a=#{a}"
          a.delete_child(b)
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(tax.root_count).to eq(0) end
          it 'has 2 folksonomies' do expect(tax.folksonomy_count).to eq(2) end
        end
        describe :delete_parent do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          b.delete_parent(a)
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(tax.root_count).to eq(0) end
          it 'has 2 folksonomies' do expect(tax.folksonomy_count).to eq(2) end
        end
      end
      context ':b -x-> :a -> :r' do
        context 'before' do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          r = tax.get_tag_by_name(:r)
          it ':r has child' do expect(r).to have_child end
          it ':a has child' do expect(a).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has no folks' do expect(tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          r = tax.get_tag_by_name(:r)
          a.delete_child(b)
          it ':r has child' do expect(r).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no psrent' do expect(b).to_not have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':b is folk' do expect(b).to be_folk end
        end
        context :delete_parent do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          r = tax.get_tag_by_name(:r)
          b.delete_parent(a)
          it ':r has child' do expect(r).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no psrent' do expect(b).to_not have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':b is folk' do expect(b).to be_folk end
        end
      end
      context ':l -> :b -x-> :a' do
        context 'before' do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          l = tax.get_tag_by_name(:l)
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          l = tax.get_tag_by_name(:l)
          a.delete_child(b)
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':b is root' do expect(b).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':a is folk' do expect(a).to be_folk end
        end
        context :delete_parent do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          l = tax.get_tag_by_name(:l)
          b.delete_parent(a)
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':b is root' do expect(b).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':a is folk' do expect(a).to be_folk end
        end
      end
      context ':a1 <- :b -x-> :a2' do
        context 'before' do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag_by_name(:a1)
          a2 = tax.get_tag_by_name(:a2)
          b = tax.get_tag_by_name(:b)
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 2 roots' do expect(tax.root_count).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag_by_name(:a1)
          a2 = tax.get_tag_by_name(:a2)
          b = tax.get_tag_by_name(:b)
          a2.delete_child(b)
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no child' do expect(a2).to_not have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':a1 is root' do expect(a1).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':a2 is folk' do expect(a2).to be_folk end
        end
        context :delete_parent do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag_by_name(:a1)
          a2 = tax.get_tag_by_name(:a2)
          b = tax.get_tag_by_name(:b)
          b.delete_parent(a2)
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no child' do expect(a2).to_not have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(tax.root_count).to eq(1) end
          it ':a1 is root' do expect(a1).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':a2 is folk' do expect(a2).to be_folk end
        end
      end
      context ':b1 -> :a <-x- :b2' do
        context 'before' do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag_by_name(:b1)
          b2 = tax.get_tag_by_name(:b2)
          a = tax.get_tag_by_name(:a)
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has parent' do expect(b2).to have_parent end
          it 'has 1 roots' do expect(tax.root_count).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag_by_name(:b1)
          b2 = tax.get_tag_by_name(:b2)
          a = tax.get_tag_by_name(:a)
          a.delete_child(b2)
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it 'has 1 roots' do expect(tax.root_count).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
        context :delete_parent do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag_by_name(:b1)
          b2 = tax.get_tag_by_name(:b2)
          a = tax.get_tag_by_name(:a)
          b2.delete_parent(a)
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it 'has 1 roots' do expect(tax.root_count).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has 1 folk' do expect(tax.folksonomy_count).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
      end
    end
  end
end
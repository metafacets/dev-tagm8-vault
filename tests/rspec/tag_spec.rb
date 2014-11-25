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
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            tax = Taxonomy.new
            tax.add_tag(:b,:a)
            @a = tax.get_tag_by_name(:a)
            @b = tax.get_tag_by_name(:b)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':a is root' do expect(@a).to be_root end
        end
        describe :delete_child do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            #puts "tag-spec.delete_child: a=#{a}"
            @a.delete_child(@b)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it 'has no roots' do expect(@tax.root_count).to eq(0) end
          it 'has 2 folksonomies' do expect(@tax.folksonomy_count).to eq(2) end
        end
        describe :delete_parent do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @b.delete_parent(@a)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it 'has no roots' do expect(@tax.root_count).to eq(0) end
          it 'has 2 folksonomies' do expect(@tax.folksonomy_count).to eq(2) end
        end
      end
      context ':b -x-> :a -> :r' do
        context 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:a,:r)
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @r = @tax.get_tag_by_name(:r)
          end
          it ':r has child' do expect(@r).to have_child end
          it ':a has child' do expect(@a).to have_child end
          it ':a has parent' do expect(@a).to have_parent end
          it ':b has parent' do expect(@b).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:a,:r)
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @r = @tax.get_tag_by_name(:r)
            @a.delete_child(@b)
          end
          it ':r has child' do expect(@r).to have_child end
          it ':a has parent' do expect(@a).to have_parent end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no psrent' do expect(@b).to_not have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':b is folk' do expect(@b).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:a,:r)
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @r = @tax.get_tag_by_name(:r)
            @b.delete_parent(@a)
          end
          it ':r has child' do expect(@r).to have_child end
          it ':a has parent' do expect(@a).to have_parent end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no psrent' do expect(@b).to_not have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':b is folk' do expect(@b).to be_folk end
        end
      end
      context ':l -> :b -x-> :a' do
        context 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @tax.add_tag(:l,:b)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @l = @tax.get_tag_by_name(:l)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':l has parent' do expect(@l).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @tax.add_tag(:l,:b)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @l = @tax.get_tag_by_name(:l)
            @a.delete_child(@b)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':l has parent' do expect(@l).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':b is root' do expect(@b).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':a is folk' do expect(@a).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @tax.add_tag(:l,:b)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @l = @tax.get_tag_by_name(:l)
            @b.delete_parent(@a)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':l has parent' do expect(@l).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':b is root' do expect(@b).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':a is folk' do expect(@a).to be_folk end
        end
      end
      context ':a1 <- :b -x-> :a2' do
        context 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
            @b = @tax.get_tag_by_name(:b)
          end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it 'has 2 roots' do expect(@tax.root_count).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
            @b = @tax.get_tag_by_name(:b)
            @a2.delete_child(@b)
          end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has no child' do expect(@a2).to_not have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a1 is root' do expect(@a1).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':a2 is folk' do expect(@a2).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
            @b = @tax.get_tag_by_name(:b)
            @b.delete_parent(@a2)
          end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has no child' do expect(@a2).to_not have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a1 is root' do expect(@a1).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':a2 is folk' do expect(@a2).to be_folk end
        end
      end
      context ':b1 -> :a <-x- :b2' do
        context 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b1,:a)
            @tax.add_tag(:b2,:a)
            @b1 = @tax.get_tag_by_name(:b1)
            @b2 = @tax.get_tag_by_name(:b2)
            @a = @tax.get_tag_by_name(:a)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b1 has parent' do expect(@b1).to have_parent end
          it ':b2 has parent' do expect(@b2).to have_parent end
          it 'has 1 roots' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b1,:a)
            @tax.add_tag(:b2,:a)
            @b1 = @tax.get_tag_by_name(:b1)
            @b2 = @tax.get_tag_by_name(:b2)
            @a = @tax.get_tag_by_name(:a)
            @a.delete_child(@b2)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b1 has parent' do expect(@b1).to have_parent end
          it ':b2 has no parent' do expect(@b2).to_not have_parent end
          it 'has 1 roots' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b1,:a)
            @tax.add_tag(:b2,:a)
            @b1 = @tax.get_tag_by_name(:b1)
            @b2 = @tax.get_tag_by_name(:b2)
            @a = @tax.get_tag_by_name(:a)
            @b2.delete_parent(@a)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b1 has parent' do expect(@b1).to have_parent end
          it ':b2 has no parent' do expect(@b2).to_not have_parent end
          it 'has 1 roots' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has 1 folk' do expect(@tax.folksonomy_count).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
      end
    end
    describe 'Taxonomy.delete_tag' do
      describe 'c -> (b) -> a => c -> a' do
        describe 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c,:b)
            @tax.add_tag(:b,:a)
            @c = @tax.get_tag_by_name(:c)
            @b = @tax.get_tag_by_name(:b)
            @a = @tax.get_tag_by_name(:a)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it 'has 1 roots' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c,:b)
            @tax.add_tag(:b,:a)
            @c = @tax.get_tag_by_name(:c)
            @a = @tax.get_tag_by_name(:a)
            @tax.delete_tag(:b)
          end
          it 'tag :b not included' do expect(@tax.has_tag?(:b)).to be_falsey end
          it ':a has child' do expect(@a).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it 'has 1 roots' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
      end
      describe 'c -> (b) -> [a1,a2] => c -> [a1,a2]' do
        describe 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c,:b)
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @c = @tax.get_tag_by_name(:c)
            @b = @tax.get_tag_by_name(:b)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
          end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it 'has 2 roots' do expect(@tax.root_count).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c,:b)
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @c = @tax.get_tag_by_name(:c)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
            @tax.delete_tag(:b)
          end
          it 'tag :b not included' do expect(@tax.has_tag?(:b)).to be_falsey end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it 'has 2 roots' do expect(@tax.root_count).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
      end
      describe '[c1,c2] -> (b) -> a => [c1,c2] -> a' do
        describe 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c1,:b)
            @tax.add_tag(:c2,:b)
            @tax.add_tag(:b,:a)
            @c1 = @tax.get_tag_by_name(:c1)
            @c2 = @tax.get_tag_by_name(:c2)
            @b = @tax.get_tag_by_name(:b)
            @a = @tax.get_tag_by_name(:a)
          end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c1 has parent' do expect(@c1).to have_parent end
          it ':c2 has parent' do expect(@c2).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c1,:b)
            @tax.add_tag(:c2,:b)
            @tax.add_tag(:b,:a)
            @c1 = @tax.get_tag_by_name(:c1)
            @c2 = @tax.get_tag_by_name(:c2)
            @a = @tax.get_tag_by_name(:a)
            @tax.delete_tag(:b)
          end
          it 'tag :b not included' do expect(@tax.has_tag?(:b)).to be_falsey end
          it ':a has child' do expect(@a).to have_child end
          it ':c1 has parent' do expect(@c1).to have_parent end
          it ':c2 has parent' do expect(@c2).to have_parent end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
      end
      describe '[c1,c2] -> (b) -> [a1,a2] => [c1,c2] -> [a1,a2]' do
        describe 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c1,:b)
            @tax.add_tag(:c2,:b)
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @c1 = @tax.get_tag_by_name(:c1)
            @c2 = @tax.get_tag_by_name(:c2)
            @b = @tax.get_tag_by_name(:b)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
          end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c1 has parent' do expect(@c1).to have_parent end
          it ':c2 has parent' do expect(@c2).to have_parent end
          it 'has 2 roots' do expect(@tax.root_count).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:c1,:b)
            @tax.add_tag(:c2,:b)
            @tax.add_tag(:b,:a1)
            @tax.add_tag(:b,:a2)
            @c1 = @tax.get_tag_by_name(:c1)
            @c2 = @tax.get_tag_by_name(:c2)
            @a1 = @tax.get_tag_by_name(:a1)
            @a2 = @tax.get_tag_by_name(:a2)
            @tax.delete_tag(:b)
          end
          it 'tag :b not included' do expect(@tax.has_tag?(:b)).to be_falsey end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':c1 has parent' do expect(@c1).to have_parent end
          it ':c2 has parent' do expect(@c2).to have_parent end
          it 'has 2 roots' do expect(@tax.root_count).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
      end
      describe 'b2 -> (a) -> b1 -> c => b2, b1 -> c' do
        describe 'before' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b1,:a)
            @tax.add_tag(:b2,:a)
            @tax.add_tag(:c,:b1)
            @a = @tax.get_tag_by_name(:a)
            @b1 = @tax.get_tag_by_name(:b1)
            @b2 = @tax.get_tag_by_name(:b2)
            @c = @tax.get_tag_by_name(:c)
          end
          it ':a has 2 children' do expect(@a.children.size).to eq(2) end
          it ':a has no parents' do expect(@a).to_not have_parent end
          it ':b1 has parent' do expect(@b1).to have_parent end
          it ':b1 has child' do expect(@b1).to have_child end
          it ':b2 has parent' do expect(@b2).to have_parent end
          it ':b2 has no children' do expect(@b2).to_not have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it ':c has no children' do expect(@c).to_not have_child end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.folksonomy_count).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            MongoMapper.connection.drop_database('tagm8')
            @tax = Taxonomy.new
            @tax.add_tag(:b1,:a)
            @tax.add_tag(:b2,:a)
            @tax.add_tag(:c,:b1)
            @b1 = @tax.get_tag_by_name(:b1)
            @b2 = @tax.get_tag_by_name(:b2)
            @c = @tax.get_tag_by_name(:c)
            @tax.delete_tag(:a)
          end
          it 'tag :a not included' do expect(@tax.has_tag?(:a)).to be_falsey end
          it ':b1 has no parents' do expect(@b1).to_not have_parent end
          it ':b1 has children' do expect(@b1).to have_child end
          it ':b2 has no parent' do expect(@b2).to_not have_parent end
          it ':b2 has no children' do expect(@b2).to_not have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it ':c has no children' do expect(@c).to_not have_child end
          it 'has 1 root' do expect(@tax.root_count).to eq(1) end
          it ':b1 is root' do expect(@b1).to be_root end
          it 'has 1 folks' do expect(@tax.folksonomy_count).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
      end
    end
  end
end
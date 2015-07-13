require 'rspec'
require_relative '../../src/app/tag'
require_relative '../../tests/fixtures/animal_01'
include AnimalTaxonomy

Tagm8Db.open('tagm8-test')

describe 'Taxonomy' do
  context 'class methods' do
    Tagm8Db.wipe
    tax1 = Taxonomy.new(name='tax1')
    Taxonomy.new(name='tax2')
    Taxonomy.new(name='tax3')
    hastax1 = Taxonomy.exists?(name='tax1')
    hastax4 = Taxonomy.exists?(name='tax4')
    otax1 = Taxonomy.get_by_name('tax1')
    otax4 = Taxonomy.get_by_name('tax4')
    ltax1 = Taxonomy.lazy('tax1')
    ltax4 = Taxonomy.lazy('tax4')
    count = Taxonomy.count
    list = Taxonomy.list.sort
    it 'existant exists' do expect(hastax1).to be_truthy end
    it 'non-existant exists' do expect(hastax4).to be_falsey end
    it 'open existing' do expect(otax1._id).to eq(tax1.id) end
    it 'open non-existant' do expect(otax4).to be_nil end
    it 'open existing' do expect(ltax1._id).to eq(tax1.id) end
    it 'open non-existant' do expect(ltax4.name).to eq('tax4') end
    it :taxonomy_count do expect(count).to eq(4) end
    it :taxonomies_by_name do expect(list).to eq(['tax1','tax2','tax3','tax4']) end
  end
  context 'empty' do
    Tagm8Db.wipe
    tax = Taxonomy.new
    [:has_tag?, :has_root?, :has_folksonomy?].each do |method|
      result = tax.send(method)
      it "#{method} is false" do expect(result).to be_falsey end
    end
  end
  context 'add_tag(:a)' do
    Tagm8Db.wipe
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
    Tagm8Db.wipe
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
      @size = tax.count_tags
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
      Tagm8Db.wipe
      @tax = animal_taxonomy(false)
    end
    it 'taxonomy has 11 tags' do expect(@tax.count_tags).to eq(11) end
    it 'taxonomy has no folks' do expect(@tax.count_folksonomies).to eq(0) end
    it 'taxonomy has 2 roots' do expect(@tax.count_roots).to eq(2) end
  end
  context 'instance methods' do
    Tagm8Db.wipe
    tax = Taxonomy.new
    subject {tax.get_lazy_tag(:my_tag)}
    methods = [:name,:children,:has_child?,:union_children,:subtract_children, :delete_child,:parents,:has_parent?,:union_parents,:subtract_parents, :delete_parent]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
    it ':name ok' do expect(subject.name).to eq(:my_tag.to_s) end
  end
  describe 'deletion integrity' do
    describe 'parent/child links' do
      describe ':b -x-> :a' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            #puts "tag-spec.delete_child: a=#{a}"
            @a.delete_child(@b)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it 'has no roots' do expect(@tax.count_roots).to eq(0) end
          it 'has 2 folksonomies' do expect(@tax.count_folksonomies).to eq(2) end
        end
        describe :delete_parent do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.add_tag(:b,:a)
            @a = @tax.get_tag_by_name(:a)
            @b = @tax.get_tag_by_name(:b)
            @b.delete_parent(@a)
          end
          it ':a has no child' do expect(@a).to_not have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it 'has no roots' do expect(@tax.count_roots).to eq(0) end
          it 'has 2 folksonomies' do expect(@tax.count_folksonomies).to eq(2) end
        end
      end
      context ':b -x-> :a -> :r' do
        context 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':b is folk' do expect(@b).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':r is root' do expect(@r).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':b is folk' do expect(@b).to be_folk end
        end
      end
      context ':l -> :b -x-> :a' do
        context 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':b is root' do expect(@b).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a is folk' do expect(@a).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':b is root' do expect(@b).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a is folk' do expect(@a).to be_folk end
        end
      end
      context ':a1 <- :b -x-> :a2' do
        context 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a1 is root' do expect(@a1).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a2 is folk' do expect(@a2).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a1 is root' do expect(@a1).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a2 is folk' do expect(@a2).to be_folk end
        end
      end
      context ':b1 -> :a <-x- :b2' do
        context 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        context :delete_child do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
        context :delete_parent do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
      end
    end
    describe 'Taxonomy.delete_tag' do
      describe 'c -> (b) -> a => c -> a' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
      end
      describe 'c -> (b) -> [a1,a2] => c -> [a1,a2]' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
      end
      describe '[c1,c2] -> (b) -> a => [c1,c2] -> a' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
      end
      describe '[c1,c2] -> (b) -> [a1,a2] => [c1,c2] -> [a1,a2]' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
      end
      describe 'b2 -> (a) -> b1 -> c => b2, b1 -> c' do
        describe 'before' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        end
        describe 'after' do
          before(:all) do
            Tagm8Db.wipe
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
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it ':b1 is root' do expect(@b1).to be_root end
          it 'has 1 folks' do expect(@tax.count_folksonomies).to eq(1) end
          it ':b2 is folk' do expect(@b2).to be_folk end
        end
      end
    end
  end
  context 'dag integrity' do
    context 'prevent recursion (:a <-+-> :a)' do
      ['fix','prevent'].each do |context|
        context "deg='#{context}'" do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag(context)
            @tax.add_tag(:a,:a)
            @a =@tax.get_tag_by_name(:a)
          end
          it 'taxonomy has 1 tag' do expect(@tax.count_tags).to eq(1) end
          it 'a has no parents' do expect(@a).to_not have_parent end
          it 'a has no children' do expect(@a).to_not have_child end
          it 'a is not root' do expect(@a).to_not be_root end
          it 'a is folk' do expect(@a).to be_folk end
        end
      end
    end
    context 'prevent reflection (:a -> :b -+-> :a)' do
      context "dag='fix' (:a -x-> :b -> :a)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('fix')
          @tax.add_tag(:a,:b)
          @tax.add_tag(:b,:a)
          @a =@tax.get_tag_by_name(:a)
          @b =@tax.get_tag_by_name(:b)
        end
        it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
        it 'roots has 1 tag' do expect(@tax.count_roots).to eq(1) end
        it 'folks is empty' do expect(@tax.count_folksonomies).to eq(0) end
        it ':a has no parent' do expect(@a).to_not have_parent end
        it ':a has child' do expect(@a).to have_child end
        it ':b has parent' do expect(@b).to have_parent end
        it ':b has no children' do expect(@b).to_not have_child end
        it ':a is root' do expect(@a).to be_root end
      end
      context "dag='prevent' (:a -> :b -x-> :a)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('prevent')
          @tax.add_tag(:a,:b)
          @tax.add_tag(:b,:a)
          @a =@tax.get_tag_by_name(:a)
          @b =@tax.get_tag_by_name(:b)
        end
        it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
        it 'roots has 1 tag' do expect(@tax.count_roots).to eq(1) end
        it 'folks is empty' do expect(@tax.count_folksonomies).to eq(0) end
        it 'b has no parent' do expect(@b).to_not have_parent end
        it 'b has child' do expect(@b).to have_child end
        it 'a has parent' do expect(@a).to have_parent end
        it 'a has no children' do expect(@a).to_not have_child end
        it 'b is root' do expect(@b).to be_root end
      end
    end
    context 'prevent looping (:a -> :b -> :c -+-> :a)' do
      context "dag='fix' (:a -x-> :b -> :c -> :a)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('fix')
          @tax.add_tag(:a,:b)
          @tax.add_tag(:b,:c)
          @tax.add_tag(:c,:a)
          @a =@tax.get_tag_by_name(:a)
          @b =@tax.get_tag_by_name(:b)
          @c =@tax.get_tag_by_name(:c)
        end
        it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
        it 'roots has 1 tag' do expect(@tax.count_roots).to eq(1) end
        it 'folks is empty' do expect(@tax.count_folksonomies).to eq(0) end
        it 'a has no parent' do expect(@a).to_not have_parent end
        it 'a has child' do expect(@a).to have_child end
        it 'c has parent' do expect(@c).to have_parent end
        it 'c has child' do expect(@c).to have_child end
        it 'b has parent' do expect(@b).to have_parent end
        it 'b has no child' do expect(@b).to_not have_child end
        it 'a is root' do expect(@a).to be_root end
      end
      context "dag='prevent' (:a -> :b -> :c -x-> :a)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('prevent')
          @tax.add_tag(:a,:b)
          @tax.add_tag(:b,:c)
          @tax.add_tag(:c,:a)
          @a =@tax.get_tag_by_name(:a)
          @b =@tax.get_tag_by_name(:b)
          @c =@tax.get_tag_by_name(:c)
        end
        it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
        it 'roots has 1 tag' do expect(@tax.count_roots).to eq(1) end
        it 'folks is empty' do expect(@tax.count_folksonomies).to eq(0) end
        it 'c has no parent' do expect(@c).to_not have_parent end
        it 'c has child' do expect(@c).to have_child end
        it 'b has parent' do expect(@b).to have_parent end
        it 'b has child' do expect(@b).to have_child end
        it 'a has parent' do expect(@a).to have_parent end
        it 'a has no child' do expect(@a).to_not have_child end
        it 'c is root' do expect(@c).to be_root end
      end
    end
    context 'prevent selective looping (:b2 <- :a -> :b1 -> :c1 -+-> :a)' do
      context "dag='fix' (:a -x-> :b1 -> :c1 -> :a -> :b2)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('fix')
          @tax.add_tag(:a,:b1)
          @tax.add_tag(:a,:b2)
          @tax.add_tag(:b1,:c1)
          @tax.add_tag(:c1,:a)
          @a =@tax.get_tag_by_name(:a)
          @b1 =@tax.get_tag_by_name(:b1)
          @b2 =@tax.get_tag_by_name(:b2)
          @c1 =@tax.get_tag_by_name(:c1)
        end
        it 'taxonomy has 4 tags' do expect(@tax.count_tags).to eq(4) end
        it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
        it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        it ':b2 has no parent' do expect(@b2).to_not have_parent end
        it ':b2 has child' do expect(@b2).to have_child end
        it ':a has parent' do expect(@a).to have_parent end
        it ':a has child' do expect(@a).to have_child end
        it ':c1 has parent' do expect(@c1).to have_parent end
        it ':c1 has child' do expect(@c1).to have_child end
        it ':b1 has parent' do expect(@b1).to have_parent end
        it ':b1 has no child' do expect(@b1).to_not have_child end
        it ':b2 is root' do expect(@b2).to be_root end
      end
      context "dag='prevent' (b2 <- :a -> :b1 -> :c1)" do
        before(:all) do
          Tagm8Db.wipe
          @tax = Taxonomy.new
          @tax.set_dag('prevent')
          @tax.add_tag(:a,:b1)
          @tax.add_tag(:a,:b2)
          @tax.add_tag(:b1,:c1)
          @tax.add_tag(:c1,:a)
          @a =@tax.get_tag_by_name(:a)
          @b1 =@tax.get_tag_by_name(:b1)
          @b2 =@tax.get_tag_by_name(:b2)
          @c1 =@tax.get_tag_by_name(:c1)
        end
        it 'taxonomy has 4 tags' do expect(@tax.count_tags).to eq(4) end
        it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
        it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
        it ':b2 has no parent' do expect(@b2).to_not have_parent end
        it ':b2 has child' do expect(@b2).to have_child end
        it ':a has parent' do expect(@a).to have_parent end
        it ':a has no child' do expect(@a).to_not have_child end
        it ':b1 has parent' do expect(@b1).to have_parent end
        it ':b1 has child' do expect(@b1).to have_child end
        it ':c1 has no parent' do expect(@c1).to_not have_parent end
        it ':c1 has child' do expect(@c1).to have_child end
        it ':b2 is root' do expect(@b2).to be_root end
        it ':c1 is root' do expect(@c1).to be_root end
      end
    end
  end
  describe :instantiate do
    describe 'tag_ddl errors' do
      [[:a],:a].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
          end
          it 'taxonomy empty' do expect(@tax.count_tags).to eq(0) end
          it 'roots empty' do expect(@tax.count_roots).to eq(0) end
          it 'folk empty' do expect(@tax.count_folksonomies).to eq(0) end
        end
      end
    end
    describe 'single tag' do
      ['[:a]',':a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
          end
          it 'taxonomy has 1 tag' do expect(@tax.count_tags).to eq(1) end
          it 'has no roots' do expect(@tax.count_roots).to eq(0) end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a is folk' do expect(@a).to be_folk end
        end
      end
    end
    describe 'discrete pair' do
      ['[:a,:b]',':a,:b'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
          end
          it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
          it 'has no roots' do expect(@tax.count_roots).to eq(0) end
          it 'has 2 folk' do expect(@tax.count_folksonomies).to eq(2) end
          it ':a is folk' do expect(@a).to be_folk end
          it ':b is folk' do expect(@b).to be_folk end
        end
      end
    end
    describe 'discrete pair errors' do
      ['a,b',':a:b',':a::b',':a,,:b','a::b','::a,,b'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
          end
          it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
          it 'has no roots' do expect(@tax.count_roots).to eq(0) end
          it 'has 2 folk' do expect(@tax.count_folksonomies).to eq(2) end
          it ':a is folk' do expect(@a).to be_folk end
          it ':b is folk' do expect(@b).to be_folk end
        end
      end
    end
    describe 'hierarchy pair' do
      ['[:a>:b]',':a>:b','[:b<:a]',':b<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
          end
          it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has no child' do expect(@b).to_not have_child end
        end
      end
    end
    describe 'hierarchy pair plus folk' do
      ['[:a>:b],:c',':a>:b,:c','[:b<:a],:c',':b<:a,:c'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
            @c =@tax.get_tag_by_name(:c)
          end
          it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has 1 folk' do expect(@tax.count_folksonomies).to eq(1) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has no child' do expect(@b).to_not have_child end
          it ':c is folk' do expect(@c).to be_folk end
        end
      end
    end
    describe 'hierarchy pair errors' do
      ['[:a>b]','a>b','a>::b','[:b<<:a]',':b<<::a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
          end
          it 'taxonomy has 2 tags' do expect(@tax.count_tags).to eq(2) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has no child' do expect(@b).to_not have_child end
        end
      end
    end
    describe 'various syntax failures' do
      [':b<><<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
          end
          it 'taxonomy empty' do expect(@tax.count_tags).to eq(0) end
        end
      end
    end
    describe 'discrete and hierarchy pairs combined' do
      ['[[:a,:b]>:c]','[:a,:b]>:c','[:c<[:a,:b]]',':c<[:a,:b]'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
            @c =@tax.get_tag_by_name(:c)
          end
          it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':b is root' do expect(@b).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has no parent' do expect(@b).to_not have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it ':c has no child' do expect(@c).to_not have_child end
        end
      end
      ['[:a>[:b,:c]]',':a>[:b,:c]','[[:b,:c]<:a]','[:b,:c]<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
            @c =@tax.get_tag_by_name(:c)
          end
          it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
          it 'has 1 roots' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has no child' do expect(@b).to_not have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it ':c has no child' do expect(@c).to_not have_child end
        end
      end
      ['[[:a1,:a2]>[:b1,:b2]]','[:a1,:a2]>[:b1,:b2]','[[:b1,:b2]<[:a1,:a2]]','[:b1,:b2]<[:a1,:a2]'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a1 =@tax.get_tag_by_name(:a1)
            @a2 =@tax.get_tag_by_name(:a2)
            @b1 =@tax.get_tag_by_name(:b1)
            @b2 =@tax.get_tag_by_name(:b2)
          end
          it 'taxonomy has 4 tags' do expect(@tax.count_tags).to eq(4) end
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it ':a1 has no parent' do expect(@a1).to_not have_parent end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has no parent' do expect(@a2).to_not have_parent end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':b1 has parent' do expect(@b1).to have_parent end
          it ':b1 has no child' do expect(@b1).to_not have_child end
          it ':b2 has parent' do expect(@b2).to have_parent end
          it ':b2 has no child' do expect(@b2).to_not have_child end
        end
      end
    end
    describe 'hierarchy triple' do
      ['[:a>:b>:c]',':a>:b>:c','[:c<:b<:a]',':c<:b<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b =@tax.get_tag_by_name(:b)
            @c =@tax.get_tag_by_name(:c)
          end
          it 'taxonomy has 3 tags' do expect(@tax.count_tags).to eq(3) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has child' do expect(@a).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c has parent' do expect(@c).to have_parent end
          it ':c has no child' do expect(@c).to_not have_child end
        end
      end
    end
    describe 'hierarchy triple and discrete pair combined' do
      ['[[:a1,:a2]>:b>[:c1,:c2]]','[:a1,:a2]>:b>[:c1,:c2]','[[:c1,:c2]<:b<[:a1,:a2]]','[:c1,:c2]<:b<[:a1,:a2]'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a1 =@tax.get_tag_by_name(:a1)
            @a2 =@tax.get_tag_by_name(:a2)
            @b =@tax.get_tag_by_name(:b)
            @c1 =@tax.get_tag_by_name(:c1)
            @c2 =@tax.get_tag_by_name(:c2)
          end
          it 'taxonomy has 5 tags' do expect(@tax.count_tags).to eq(5) end
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a1 is root' do expect(@a1).to be_root end
          it ':a2 is root' do expect(@a2).to be_root end
          it ':a1 has no parent' do expect(@a1).to_not have_parent end
          it ':a1 has child' do expect(@a1).to have_child end
          it ':a2 has no parent' do expect(@a2).to_not have_parent end
          it ':a2 has child' do expect(@a2).to have_child end
          it ':b has parent' do expect(@b).to have_parent end
          it ':b has child' do expect(@b).to have_child end
          it ':c1 has parent' do expect(@c1).to have_parent end
          it ':c1 has no child' do expect(@c1).to_not have_child end
          it ':c2 has parent' do expect(@c2).to have_parent end
          it ':c2 has no child' do expect(@c2).to_not have_child end
        end
      end
    end
    describe 'siblings nest hierarchy' do
      [':a>[:b1,:b2>[:c21,:c22],:b3]',':a>[:b2>[:c21,:c22],:b1,:b3]',':a>[:b1,:b3,:b2>[:c21,:c22]]','[:b1,[:c21,:c22]<:b2,:b3]<:a','[[:c21,:c22]<:b2,:b1,:b3]<:a','[:b1,:b3,[:c21,:c22]<:b2]<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b1 =@tax.get_tag_by_name(:b1)
            @b2 =@tax.get_tag_by_name(:b2)
            @b3 = @tax.get_tag_by_name(:b3)
            @c21 = @tax.get_tag_by_name(:c21)
            @c22 = @tax.get_tag_by_name(:c22)
          end
          it 'taxonomy has 6 tags' do expect(@tax.count_tags).to eq(6) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has 3 children' do expect(@a.children.size).to eq(3) end
          it ':b1 has 1 parent' do expect(@b1.parents.size).to eq(1) end
          it ':b2 has 1 parent' do expect(@b2.parents.size).to eq(1) end
          it ':b3 has 1 parent' do expect(@b3.parents.size).to eq(1) end
          it ':b1 has no child' do expect(@b1).to_not have_child end
          it ':b2 has 2 children' do expect(@b2.children.size).to eq(2) end
          it ':b3 has no child' do expect(@b3).to_not have_child end
          it ':c21 has parent' do expect(@c21).to have_parent end
          it ':c21 has no child' do expect(@c21).to_not have_child end
          it ':c22 has parent' do expect(@c22).to have_parent end
          it ':c22 has no child' do expect(@c22).to_not have_child end
        end
      end
    end
    describe 'siblings nest mixed hierarchy' do
      [':a>[:b1,[:c21,:c22]<:b2,:b3]','[:b1,:b2>[:c21,:c22],:b3]<:a',':a>[[:c21,:c22]<:b2,:b1,:b3]','[:b2>[:c21,:c22],:b1,:b3]<:a',':a>[:b1,:b3,[:c21,:c22]<:b2]','[:b1,:b3,:b2>[:c21,:c22]]<:a'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @a =@tax.get_tag_by_name(:a)
            @b1 =@tax.get_tag_by_name(:b1)
            @b2 =@tax.get_tag_by_name(:b2)
            @b3 = @tax.get_tag_by_name(:b3)
            @c21 = @tax.get_tag_by_name(:c21)
            @c22 = @tax.get_tag_by_name(:c22)
          end
          it 'taxonomy has 6 tags' do expect(@tax.count_tags).to eq(6) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':a is root' do expect(@a).to be_root end
          it ':a has no parent' do expect(@a).to_not have_parent end
          it ':a has 3 children' do expect(@a.children.size).to eq(3) end
          it ':b1 has 1 parent' do expect(@b1.parents.size).to eq(1) end
          it ':b2 has 1 parent' do expect(@b2.parents.size).to eq(1) end
          it ':b3 has 1 parent' do expect(@b3.parents.size).to eq(1) end
          it ':b1 has no child' do expect(@b1).to_not have_child end
          it ':b2 has 2 children' do expect(@b2.children.size).to eq(2) end
          it ':b3 has no child' do expect(@b3).to_not have_child end
          it ':c21 has parent' do expect(@c21).to have_parent end
          it ':c21 has no child' do expect(@c21).to_not have_child end
          it ':c22 has parent' do expect(@c22).to have_parent end
          it ':c22 has no child' do expect(@c22).to_not have_child end
        end
      end
    end
    describe 'double nested hierarchy with siblings' do
      ['[[:carp,:herring]<:fish,:insect]<:animal','[:insect,[:carp,:herring]<:fish]<:animal',':animal>[:insect,:fish>[:carp,:herring]]',':animal>[:fish>[:carp,:herring],:insect]'].each do |ddl|
        describe ddl do
          before(:all) do
            Tagm8Db.wipe
            @tax = Taxonomy.new
            @tax.set_dag('prevent')
            @tax.instantiate(ddl)
            @animal = @tax.get_tag_by_name(:animal)
            @fish = @tax.get_tag_by_name(:fish)
            @insect = @tax.get_tag_by_name(:insect)
            @carp = @tax.get_tag_by_name(:carp)
            @herring = @tax.get_tag_by_name(:herring)
          end
          it 'taxonomy has 5 tags' do expect(@tax.count_tags).to eq(5) end
          it 'has 1 root' do expect(@tax.count_roots).to eq(1) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':animal is root' do expect(@animal).to be_root end
          it ':animal has no parent' do expect(@animal).to_not have_parent end
          it ':animal has 2 children' do expect(@animal.children.size).to eq(2) end
          it ':fish has 1 parent' do expect(@fish.parents.size).to eq(1) end
          it ':fish has 2 children' do expect(@fish.children.size).to eq(2) end
          it ':insect has 1 parent' do expect(@insect.parents.size).to eq(1) end
          it ':insect has no child' do expect(@insect).to_not have_child end
          it ':carp has 1 parent' do expect(@carp.parents.size).to eq(1) end
          it ':carp has no child' do expect(@carp).to_not have_child end
          it ':herring has 1 parent' do expect(@herring.parents.size).to eq(1) end
          it ':herring has no child' do expect(@herring).to_not have_child end
        end
      end
    end
    describe 'animal_taxonomy' do
      ['add_tags','instantiate'].each do |method|
        describe "#{method}" do
          before(:all) do
            Tagm8Db.wipe
            @tax = animal_taxonomy(method=='instantiate')
            @animal = @tax.get_tag_by_name(:animal)
            @food = @tax.get_tag_by_name(:food)
          end
          it 'taxonomy has 11 tags' do expect(@tax.count_tags).to eq(11) end
          it 'has 2 roots' do expect(@tax.count_roots).to eq(2) end
          it 'has no folks' do expect(@tax.count_folksonomies).to eq(0) end
          it ':animal is root' do expect(@animal).to be_root end
          it ':food is root' do expect(@food).to be_root end
        end
      end
    end
  end
  describe 'derivation methods' do
    describe Tag do
      describe :get_descendents do
        tests = [[':a>:b>:c',[:b,:c]]\
                ,[':a>[:b1,:b2]',[:b1,:b2]]\
                ,[':a>[:b1,:b2>:c]',[:b1,:b2,:c]]\
                ,[':a>[:b1,:b2]>:c',[:b1,:b2,:c]]\
                ,[':a>[:b1>[:c1,:c2],:b2,:b3>[:c3,:c4,:c5]]',[:b1,:b2,:b3,:c1,:c2,:c3,:c4,:c5]]
        ]
        tests.each do |test|
          Tagm8Db.wipe
          tax = Taxonomy.new
          tax.instantiate(test[0])
          a = tax.get_tag_by_name(:a)
          desc = a.get_descendents.map {|d| d.name.to_sym}.sort
          desc_ok = (desc&test[1]) == test[1]
          it "descendents of :a from #{test[0]} = #{test[1]}" do expect(desc_ok).to be true end
        end
      end
      describe :get_ancestors do
        tests = [[':c>:b>:a',[:b,:c]]\
                ,['[:b1,:b2]>:a',[:b1,:b2]]\
                ,[':b1>:a<:b2<:c',[:b1,:b2,:c]]\
                ,[':a<[:b1,:b2]<:c',[:b1,:b2,:c]]\
                ,['[:c1,:c2]>:b1>:a<:b2<[:c3,:c4,:c5]',[:b1,:b2,:c1,:c2,:c3,:c4,:c5]]
        ]
        tests.each do |test|
          Tagm8Db.wipe
          tax = Taxonomy.new
          tax.instantiate(test[0])
          a = tax.get_tag_by_name(:a)
          ancs = a.get_ancestors.map {|d| d.name.to_sym}.sort
          ancs_ok = (ancs&test[1]) == test[1]
          it "ancestors of :a from #{test[0]} = #{test[1]}" do expect(ancs_ok).to be true end
        end
      end
      describe :query_items do
        describe ':a(i1)>[:b(i2,i3),:c(i3)]' do
          Tagm8Db.wipe
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          tax.instantiate(':a>[:b,:c]')
          a = tax.get_tag_by_name(:a)
          b = tax.get_tag_by_name(:b)
          c = tax.get_tag_by_name(:c)
          i1 = alm.add_item('i1')
          i2 = alm.add_item('i2')
          i3 = alm.add_item('i3')
          a.union_items([i1])
          b.union_items([i2,i3])
          c.union_items([i3])
          #a.items = [i1]
          #b.items = [i2,i3]
          #c.items = [i3]
          query_items_a = a.query_items.map {|item| item.name.to_sym}.sort
          query_items_b = b.query_items.map {|item| item.name.to_sym}.sort
          query_items_c = c.query_items.map {|item| item.name.to_sym}.sort
          it "a.query_items = [:i1,:i2,:i3]" do expect(query_items_a).to eq([:i1,:i2,:i3]) end
          it "b.query_items = [:i2,:i3]" do expect(query_items_b).to eq([:i2,:i3]) end
          it "c.query_items = [:i3]" do expect(query_items_c).to eq([:i3]) end
        end
      end
    end
    describe Taxonomy do
      describe :query_items do
        describe 'tax=album1+album2+F,album1=:a(i1)>[:b1(i2)>[:c1(i3),:c2(i3,i4)],:b2>[:c3,:c4(i4)]],F=:x(i6),album2=:c4(i5)' do
          describe 'basic syntax' do
            tests = [['#a',[:i1,:i2,:i3,:i4,:i5],[:i1,:i2,:i3,:i4]]\
                    ,[':a',[:i1,:i2,:i3,:i4,:i5],[:i1,:i2,:i3,:i4]]\
                    ,['#b1',[:i2,:i3,:i4],[:i2,:i3,:i4]]\
                    ,['#b2',[:i4,:i5],[:i4]]\
                    ,['#c1',[:i3],[:i3]]\
                    ,['#c2',[:i3,:i4],[:i3,:i4]]\
                    ,['#c3',[],[]]\
                    ,['#c4',[:i4,:i5],[:i4]]\
                    ,['#x',[:i6],[:i6]]\
                    ,['#c4|#c1',[:i3,:i4,:i5],[:i3,:i4]]\
                    ,['#c4&#c1',[],[]]\
                    ,['#c4|#c2',[:i3,:i4,:i5],[:i3,:i4]]\
                    ,['#c4&#c2',[:i4],[:i4]]\
                    ,['#c4#c2',[:i4],[:i4]]\
                    ,['(#c4&#c2)|#x',[:i4,:i6],[:i4,:i6]]\
                    ]
            tests.each do |test|
              Tagm8Db.wipe
              tax = Taxonomy.new
              alm1 = tax.add_album('alm1')
              alm2 = tax.add_album('alm2')
              tax.instantiate(':a>[:b1>[:c1,:c2],:b2>[:c3,:c4]]')
              #puts tax.tags
              #Item.taxonomy = tax
              alm1.add_item("i1\n#a")
              alm1.add_item("i2\n#b1")
              alm1.add_item("i3\n#c1,c2")
              alm1.add_item("i4\n#c2,c4")
              alm1.add_item("i6\n#x")
              alm2.add_item("i5\n#c4")
              #              puts "taxonomies=#{Taxonomy.taxonomies}, albums=#{Album.albums}, Taxonomy.taxonomy_count=#{Taxonomy.taxonomy_count}"
              result_tax = tax.query_items(test[0]).map {|item| item.name.to_sym}.sort
              result_alm1 = alm1.query_items(test[0]).map {|item| item.name.to_sym}.sort
              it "tax_query=#{test[0]}, result=#{test[1]}" do expect(result_tax).to eq(test[1]) end
              it "album1_query=#{test[0]}, result=#{test[2]}" do expect(result_alm1).to eq(test[2]) end
            end
          end
          describe 'alternate, poor or bad syntax' do
            tests = [['#A',[:i1,:i2,:i3,:i4]]\
                    ,['#:a',[:i1,:i2,:i3,:i4]]\
                    ,['a',[:i1,:i2,:i3,:i4]]\
                    ,[':a',[:i1,:i2,:i3,:i4]]\
                    ,['#c4,#c1',[:i3,:i4]]\
                    ,['#c4,|#c1',[:i3,:i4]]\
                    ,['#c4|,#c1',[:i3,:i4]]\
                    ,['#c4+#c2',[:i4]]\
                    ,['#c4+&#c2',[:i4]]\
                    ,['#c4&+#c2',[:i4]]\
                    ,['#c4#c2',[:i4]]\
                    ,['(#c4&#c2|#x',[]]\
                    ,['#x_',[]]\
                    ,['#1x',[]]\
                    ,['#y',[]]\
                    ]
            tests.each do |test|
              Tagm8Db.wipe
              tax = Taxonomy.new
              alm = tax.add_album('alm')
              tax.instantiate(':a>[:b1>[:c1,:c2],:b2>[:c3,:c4]]')
              #puts tax.tags
              #Item.taxonomy = tax
              alm.add_item("i1\n#a")
              alm.add_item("i2\n#b1")
              alm.add_item("i3\n#c1,c2")
              alm.add_item("i4\n#c2,c4")
              alm.add_item("i5\n#x")
              result = tax.query_items(test[0]).map {|item| item.name.to_sym}.sort
              it "query=#{test[0]}, result=#{test[1]}" do expect(result).to eq(test[1]) end
            end
          end
        end
      end
    end
  end
end

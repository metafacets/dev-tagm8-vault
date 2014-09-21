require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\tag.rb'
#require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\debug.rb'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tests\fixtures\animal_01.rb'
include AnimalTaxonomy

describe 'Taxonomy/Tag' do
  context ':animal > :mouse, :car' do
    before(:all) do
      tax = Taxonomy.new
      tax.add_tag(:mouse, :animal)
      tax.add_tag(:car)
      @animal = tax.get_tag(:animal)
      @mouse = tax.get_tag(:mouse)
      @car = tax.get_tag(:car)
      @taxonomy = tax.tags
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
      tax = animal_taxonomy(false)
      all_folks = tax.tags.values.select {|tag| tag.folk?}
      @omitted_folks = (all_folks-tax.folksonomy)
      @non_folks = (tax.folksonomy-all_folks)
      @taxonomy = tax.tags
    end
    it 'taxonomy has 11 tags' do expect(@taxonomy.size).to eq(11) end
    it 'includes all folks' do expect(@omitted_folks).to be_empty end
    it 'includes only folks' do expect(@non_folks).to be_empty end
  end
  context 'roots' do
    before(:all) do
      tax = animal_taxonomy(false)
      all_roots = tax.tags.values.select {|tag| tag.root?}
      @omitted_roots = (all_roots-tax.roots)
      @non_roots = (tax.roots-all_roots)
      @taxonomy = tax.tags
    end
    it 'taxonomy has 11 tags' do expect(@taxonomy.size).to eq(11) end
    it 'includes all roots' do expect(@omitted_roots).to be_empty end
    it 'includes only roots' do expect(@non_roots).to be_empty end
  end
  context 'instance methods' do
    tax = Taxonomy.new
    subject {tax.get_lazy_tag(:my_tag)}
    methods = [:name,:children,:has_child?,:add_children,:delete_child,:parents,:has_parent?,:add_parents,:delete_parent]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
    it ':name ok' do expect(subject.name).to eq(:my_tag) end
  end
  describe 'deletion integrity' do
    describe 'parent/child links' do
      describe ':b -x-> :a' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':a is root' do expect(a).to be_root end
        end
        describe :delete_child do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          a.delete_child(b)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(roots).to be_empty end
          it 'has 2 folksonomies' do expect(folks.size).to eq(2) end
        end
        describe :delete_parent do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          b.delete_parent(a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(roots).to be_empty end
          it 'has 2 folksonomies' do expect(folks.size).to eq(2) end
        end
      end
      context ':b -x-> :a -> :r' do
        context 'before' do
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          r = tax.get_tag(:r)
          roots = tax.roots
          folks = tax.folksonomy
          it ':r has child' do expect(r).to have_child end
          it ':a has child' do expect(a).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          r = tax.get_tag(:r)
          a.delete_child(b)
          roots = tax.roots
          folks = tax.folksonomy
          it ':r has child' do expect(r).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no psrent' do expect(b).to_not have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':b is folk' do expect(b).to be_folk end
        end
        context :delete_parent do
          tax = Taxonomy.new
          tax.add_tag(:a,:r)
          tax.add_tag(:b,:a)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          r = tax.get_tag(:r)
          b.delete_parent(a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':r has child' do expect(r).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no psrent' do expect(b).to_not have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':b is folk' do expect(b).to be_folk end
        end
      end
      context ':l -> :b -x-> :a' do
        context 'before' do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          l = tax.get_tag(:l)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          l = tax.get_tag(:l)
          a.delete_child(b)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':b is root' do expect(b).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a is folk' do expect(a).to be_folk end
        end
        context :delete_parent do
          tax = Taxonomy.new
          tax.add_tag(:b,:a)
          tax.add_tag(:l,:b)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          l = tax.get_tag(:l)
          b.delete_parent(a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':b is root' do expect(b).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a is folk' do expect(a).to be_folk end
        end
      end
      context ':a1 <- :b -x-> :a2' do
        context 'before' do
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          b = tax.get_tag(:b)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          b = tax.get_tag(:b)
          a2.delete_child(b)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no child' do expect(a2).to_not have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a1 is root' do expect(a1).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a2 is folk' do expect(a2).to be_folk end
        end
        context :delete_parent do
          tax = Taxonomy.new
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          b = tax.get_tag(:b)
          b.delete_parent(a2)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no child' do expect(a2).to_not have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a1 is root' do expect(a1).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a2 is folk' do expect(a2).to be_folk end
        end
      end
      context ':b1 -> :a <-x- :b2' do
        context 'before' do
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          a = tax.get_tag(:a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has parent' do expect(b2).to have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          a = tax.get_tag(:a)
          a.delete_child(b2)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
        context :delete_parent do
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          a = tax.get_tag(:a)
          b2.delete_parent(a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
      end
    end
    describe 'Taxonomy.delete_tag' do
      describe 'c -> (b) -> a => c -> a' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:c,:b)
          tax.add_tag(:b,:a)
          c = tax.get_tag(:c)
          b = tax.get_tag(:b)
          a = tax.get_tag(:a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        describe 'after' do
          tax = Taxonomy.new
          tax.add_tag(:c,:b)
          tax.add_tag(:b,:a)
          c = tax.get_tag(:c)
          a = tax.get_tag(:a)
          tax.delete_tag(:b)
          tags = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'tag :b not included' do expect(tags).to_not have_key(:b) end
          it ':a has child' do expect(a).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
      end
      describe 'c -> (b) -> [a1,a2] => c -> [a1,a2]' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:c,:b)
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          c = tax.get_tag(:c)
          b = tax.get_tag(:b)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        describe 'after' do
          tax = Taxonomy.new
          tax.add_tag(:c,:b)
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          c = tax.get_tag(:c)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          tax.delete_tag(:b)
          tags = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'tag :b not included' do expect(tags).to_not have_key(:b) end
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
      end
      describe '[c1,c2] -> (b) -> a => [c1,c2] -> a' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:c1,:b)
          tax.add_tag(:c2,:b)
          tax.add_tag(:b,:a)
          c1 = tax.get_tag(:c1)
          c2 = tax.get_tag(:c2)
          b = tax.get_tag(:b)
          a = tax.get_tag(:a)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c1 has parent' do expect(c1).to have_parent end
          it ':c2 has parent' do expect(c2).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        describe 'after' do
          tax = Taxonomy.new
          tax.add_tag(:c1,:b)
          tax.add_tag(:c2,:b)
          tax.add_tag(:b,:a)
          c1 = tax.get_tag(:c1)
          c2 = tax.get_tag(:c2)
          a = tax.get_tag(:a)
          tax.delete_tag(:b)
          tags = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'tag :b not included' do expect(tags).to_not have_key(:b) end
          it ':a has child' do expect(a).to have_child end
          it ':c1 has parent' do expect(c1).to have_parent end
          it ':c2 has parent' do expect(c2).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
      end
      describe '[c1,c2] -> (b) -> [a1,a2] => [c1,c2] -> [a1,a2]' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:c1,:b)
          tax.add_tag(:c2,:b)
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          c1 = tax.get_tag(:c1)
          c2 = tax.get_tag(:c2)
          b = tax.get_tag(:b)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c1 has parent' do expect(c1).to have_parent end
          it ':c2 has parent' do expect(c2).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        describe 'after' do
          tax = Taxonomy.new
          tax.add_tag(:c1,:b)
          tax.add_tag(:c2,:b)
          tax.add_tag(:b,:a1)
          tax.add_tag(:b,:a2)
          c1 = tax.get_tag(:c1)
          c2 = tax.get_tag(:c2)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          tax.delete_tag(:b)
          tags = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'tag :b not included' do expect(tags).to_not have_key(:b) end
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':c1 has parent' do expect(c1).to have_parent end
          it ':c2 has parent' do expect(c2).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
      end
      describe 'b2 -> (a) -> b1 -> c => b2, b1 -> c' do
        describe 'before' do
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          tax.add_tag(:c,:b1)
          a = tax.get_tag(:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          c = tax.get_tag(:c)
          roots = tax.roots
          folks = tax.folksonomy
          it ':a has 2 children' do expect(a.children.size).to eq(2) end
          it ':a has no parents' do expect(a).to_not have_parent end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b1 has child' do expect(b1).to have_child end
          it ':b2 has parent' do expect(b2).to have_parent end
          it ':b2 has no children' do expect(b2).to_not have_child end
          it ':c has parent' do expect(c).to have_parent end
          it ':c has no children' do expect(c).to_not have_child end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        describe 'after' do
          tax = Taxonomy.new
          tax.add_tag(:b1,:a)
          tax.add_tag(:b2,:a)
          tax.add_tag(:c,:b1)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          c = tax.get_tag(:c)
          tax.delete_tag(:a)
          tags = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'tag :a not included' do expect(tags).to_not have_key(:a) end
          it ':b1 has no parents' do expect(b1).to_not have_parent end
          it ':b1 has children' do expect(b1).to have_child end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it ':b2 has no children' do expect(b2).to_not have_child end
          it ':c has parent' do expect(c).to have_parent end
          it ':c has no children' do expect(c).to_not have_child end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':b1 is root' do expect(b1).to be_root end
          it 'has 1 folks' do expect(folks.size).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
      end
    end
  end
  context 'dag integrity' do
    context 'prevent recursion (:a <-+-> :a)' do
      [:dag_fix,:dag_prevent].each do |context|
        context context do
          tax = Taxonomy.new
          tax.send(context)
          tax.add_tag(:a,:a)
          taxonomy = tax.tags
          a = tax.get_tag(:a)
          it 'taxonomy has 1 tag' do expect(taxonomy.size).to eq(1) end
          it 'a has no parents' do expect(a).to_not have_parent end
          it 'a has no children' do expect(a).to_not have_child end
          it 'a is not root' do expect(a).to_not be_root end
          it 'a is folk' do expect(a).to be_folk end
        end
      end
    end
    context 'prevent reflection (:a -> :b -+-> :a)' do
      context ':dag_fix (:a -x-> :b -> :a)' do
        tax = Taxonomy.new
        tax.dag_fix
        tax.add_tag(:a,:b)
        tax.add_tag(:b,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b = tax.get_tag(:b)
        it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
        it 'roots has 1 tag' do expect(roots.size).to eq(1) end
        it 'folks is empty' do expect(folks.size).to eq(0) end
        it ':a has no parent' do expect(a).to_not have_parent end
        it ':a has child' do expect(a).to have_child end
        it ':b has parent' do expect(b).to have_parent end
        it ':b has no children' do expect(b).to_not have_child end
        it ':a is root' do expect(a).to be_root end
      end
      context ':dag_prevent (:a -> :b -x-> :a)' do
        tax = Taxonomy.new
        tax.dag_prevent
        tax.add_tag(:a,:b)
        tax.add_tag(:b,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b = tax.get_tag(:b)
        it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
        it 'roots has 1 tag' do expect(roots.size).to eq(1) end
        it 'folks is empty' do expect(folks.size).to eq(0) end
        it 'b has no parent' do expect(b).to_not have_parent end
        it 'b has child' do expect(b).to have_child end
        it 'a has parent' do expect(a).to have_parent end
        it 'a has no children' do expect(a).to_not have_child end
        it 'b is root' do expect(b).to be_root end
      end
    end
    context 'prevent looping (:a -> :b -> :c -+-> :a)' do
      context ':dag_fix (:a -x-> :b -> :c -> :a)' do
        tax = Taxonomy.new
        tax.dag_fix
        tax.add_tag(:a,:b)
        tax.add_tag(:b,:c)
        tax.add_tag(:c,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b = tax.get_tag(:b)
        c = tax.get_tag(:c)
        it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
        it 'roots has 1 tag' do expect(roots.size).to eq(1) end
        it 'folks is empty' do expect(folks.size).to eq(0) end
        it 'a has no parent' do expect(a).to_not have_parent end
        it 'a has child' do expect(a).to have_child end
        it 'c has parent' do expect(c).to have_parent end
        it 'c has child' do expect(c).to have_child end
        it 'b has parent' do expect(b).to have_parent end
        it 'b has no child' do expect(b).to_not have_child end
        it 'a is root' do expect(a).to be_root end
      end
      context ':dag_prevent (:a -> :b -> :c -x-> :a)' do
        tax = Taxonomy.new
        tax.dag_prevent
        tax.add_tag(:a,:b)
        tax.add_tag(:b,:c)
        tax.add_tag(:c,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b = tax.get_tag(:b)
        c = tax.get_tag(:c)
        it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
        it 'roots has 1 tag' do expect(roots.size).to eq(1) end
        it 'folks is empty' do expect(folks.size).to eq(0) end
        it 'c has no parent' do expect(c).to_not have_parent end
        it 'c has child' do expect(c).to have_child end
        it 'b has parent' do expect(b).to have_parent end
        it 'b has child' do expect(b).to have_child end
        it 'a has parent' do expect(a).to have_parent end
        it 'a has no child' do expect(a).to_not have_child end
        it 'c is root' do expect(c).to be_root end
      end
    end
    context 'prevent selective looping (:b2 <- :a -> :b1 -> :c1 -+-> :a)' do
      context ':dag_fix (:a -x-> :b1 -> :c1 -> :a -> :b2)' do
        tax = Taxonomy.new
        tax.dag_fix
        tax.add_tag(:a,:b1)
        tax.add_tag(:a,:b2)
        tax.add_tag(:b1,:c1)
        tax.add_tag(:c1,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b1 = tax.get_tag(:b1)
        b2 = tax.get_tag(:b2)
        c1 = tax.get_tag(:c1)
        it 'taxonomy has 4 tags' do expect(taxonomy.size).to eq(4) end
        it 'has 1 root' do expect(roots.size).to eq(1) end
        it 'has no folks' do expect(folks.size).to eq(0) end
        it ':b2 has no parent' do expect(b2).to_not have_parent end
        it ':b2 has child' do expect(b2).to have_child end
        it ':a has parent' do expect(a).to have_parent end
        it ':a has child' do expect(a).to have_child end
        it ':c1 has parent' do expect(c1).to have_parent end
        it ':c1 has child' do expect(c1).to have_child end
        it ':b1 has parent' do expect(b1).to have_parent end
        it ':b1 has no child' do expect(b1).to_not have_child end
        it ':b2 is root' do expect(b2).to be_root end
      end
      context ':dag_prevent (b2 <- :a -> :b1 -> :c1)' do
        tax = Taxonomy.new
        tax.dag_prevent
        tax.add_tag(:a,:b1)
        tax.add_tag(:a,:b2)
        tax.add_tag(:b1,:c1)
        tax.add_tag(:c1,:a)
        taxonomy = tax.tags
        roots = tax.roots
        folks = tax.folksonomy
        a = tax.get_tag(:a)
        b1 = tax.get_tag(:b1)
        b2 = tax.get_tag(:b2)
        c1 = tax.get_tag(:c1)
        it 'taxonomy has 4 tags' do expect(taxonomy.size).to eq(4) end
        it 'has 2 roots' do expect(roots.size).to eq(2) end
        it 'has no folks' do expect(folks.size).to eq(0) end
        it ':b2 has no parent' do expect(b2).to_not have_parent end
        it ':b2 has child' do expect(b2).to have_child end
        it ':a has parent' do expect(a).to have_parent end
        it ':a has no child' do expect(a).to_not have_child end
        it ':b1 has parent' do expect(b1).to have_parent end
        it ':b1 has child' do expect(b1).to have_child end
        it ':c1 has no parent' do expect(c1).to_not have_parent end
        it ':c1 has child' do expect(c1).to have_child end
        it ':b2 is root' do expect(b2).to be_root end
        it ':c1 is root' do expect(c1).to be_root end
      end
    end
  end
  describe :instantiate do
    describe 'tag_ddl errors' do
      [[:a],:a].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy empty' do expect(taxonomy.size).to eq(0) end
          it 'roots empty' do expect(roots.size).to eq(0) end
          it 'folk empty' do expect(folks.size).to eq(0) end
        end
      end
    end
    describe 'single tag' do
      ['[:a]',':a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 1 tag' do expect(taxonomy.size).to eq(1) end
          it 'has no roots' do expect(roots.size).to eq(0) end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a is folk' do expect(a).to be_folk end
        end
      end
    end
    describe 'discrete pair' do
      ['[:a,:b]',':a,:b'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
          it 'has no roots' do expect(roots.size).to eq(0) end
          it 'has 2 folk' do expect(folks.size).to eq(2) end
          it ':a is folk' do expect(a).to be_folk end
          it ':b is folk' do expect(b).to be_folk end
        end
      end
    end
    describe 'discrete pair errors' do
      ['a,b',':a:b',':a::b',':a,,:b','a::b','::a,,b'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
          it 'has no roots' do expect(roots.size).to eq(0) end
          it 'has 2 folk' do expect(folks.size).to eq(2) end
          it ':a is folk' do expect(a).to be_folk end
          it ':b is folk' do expect(b).to be_folk end
        end
      end
    end
    describe 'hierarchy pair' do
      ['[:a>:b]',':a>:b','[:b<:a]',':b<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has no child' do expect(b).to_not have_child end
        end
      end
    end
    describe 'hierarchy pair errors' do
      ['[:a>b]','a>b','a>::b','[:b<<:a]',':b<<::a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 2 tags' do expect(taxonomy.size).to eq(2) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has no child' do expect(b).to_not have_child end
        end
      end
    end
    describe 'various syntax failures' do
      [':b<><<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          taxonomy = tax.tags
          it 'taxonomy empty' do expect(taxonomy.size).to eq(0) end
        end
      end
    end
    describe 'discrete and hierarchy pairs combined' do
      ['[[:a,:b]>:c]','[:a,:b]>:c','[:c<[:a,:b]]',':c<[:a,:b]'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          c = tax.get_tag(:c)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':b is root' do expect(b).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has child' do expect(a).to have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it ':c has no child' do expect(c).to_not have_child end
        end
      end
      ['[:a>[:b,:c]]',':a>[:b,:c]','[[:b,:c]<:a]','[:b,:c]<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          c = tax.get_tag(:c)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has no child' do expect(b).to_not have_child end
          it ':c has parent' do expect(c).to have_parent end
          it ':c has no child' do expect(c).to_not have_child end
        end
      end
      ['[[:a1,:a2]>[:b1,:b2]]','[:a1,:a2]>[:b1,:b2]','[[:b1,:b2]<[:a1,:a2]]','[:b1,:b2]<[:a1,:a2]'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 4 tags' do expect(taxonomy.size).to eq(4) end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it ':a1 has no parent' do expect(a1).to_not have_parent end
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no parent' do expect(a2).to_not have_parent end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b1 has no child' do expect(b1).to_not have_child end
          it ':b2 has parent' do expect(b2).to have_parent end
          it ':b2 has no child' do expect(b2).to_not have_child end
        end
      end
    end
    describe 'hierarchy triple' do
      ['[:a>:b>:c]',':a>:b>:c','[:c<:b<:a]',':c<:b<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b = tax.get_tag(:b)
          c = tax.get_tag(:c)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 3 tags' do expect(taxonomy.size).to eq(3) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c has parent' do expect(c).to have_parent end
          it ':c has no child' do expect(c).to_not have_child end
        end
      end
    end
    describe 'hierarchy triple and discrete pair combined' do
      ['[[:a1,:a2]>:b>[:c1,:c2]]','[:a1,:a2]>:b>[:c1,:c2]','[[:c1,:c2]<:b<[:a1,:a2]]','[:c1,:c2]<:b<[:a1,:a2]'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a1 = tax.get_tag(:a1)
          a2 = tax.get_tag(:a2)
          b = tax.get_tag(:b)
          c1 = tax.get_tag(:c1)
          c2 = tax.get_tag(:c2)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 5 tags' do expect(taxonomy.size).to eq(5) end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it ':a1 has no parent' do expect(a1).to_not have_parent end
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no parent' do expect(a2).to_not have_parent end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':c1 has parent' do expect(c1).to have_parent end
          it ':c1 has no child' do expect(c1).to_not have_child end
          it ':c2 has parent' do expect(c2).to have_parent end
          it ':c2 has no child' do expect(c2).to_not have_child end
        end
      end
    end
    describe 'siblings nest hierarchy' do
      [':a>[:b1,:b2>[:c21,:c22],:b3]',':a>[:b2>[:c21,:c22],:b1,:b3]',':a>[:b1,:b3,:b2>[:c21,:c22]]','[:b1,[:c21,:c22]<:b2,:b3]<:a','[[:c21,:c22]<:b2,:b1,:b3]<:a','[:b1,:b3,[:c21,:c22]<:b2]<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          b3 = tax.get_tag(:b3)
          c21 = tax.get_tag(:c21)
          c22 = tax.get_tag(:c22)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 6 tags' do expect(taxonomy.size).to eq(6) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has 3 children' do expect(a.children.size).to eq(3) end
          it ':b1 has 1 parent' do expect(b1.parents.size).to eq(1) end
          it ':b2 has 1 parent' do expect(b2.parents.size).to eq(1) end
          it ':b3 has 1 parent' do expect(b3.parents.size).to eq(1) end
          it ':b1 has no child' do expect(b1).to_not have_child end
          it ':b2 has 2 children' do expect(b2.children.size).to eq(2) end
          it ':b3 has no child' do expect(b3).to_not have_child end
          it ':c21 has parent' do expect(c21).to have_parent end
          it ':c21 has no child' do expect(c21).to_not have_child end
          it ':c22 has parent' do expect(c22).to have_parent end
          it ':c22 has no child' do expect(c22).to_not have_child end
        end
      end
    end
    describe 'siblings nest mixed hierarchy' do
      [':a>[:b1,[:c21,:c22]<:b2,:b3]','[:b1,:b2>[:c21,:c22],:b3]<:a',':a>[[:c21,:c22]<:b2,:b1,:b3]','[:b2>[:c21,:c22],:b1,:b3]<:a',':a>[:b1,:b3,[:c21,:c22]<:b2]','[:b1,:b3,:b2>[:c21,:c22]]<:a'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          a = tax.get_tag(:a)
          b1 = tax.get_tag(:b1)
          b2 = tax.get_tag(:b2)
          b3 = tax.get_tag(:b3)
          c21 = tax.get_tag(:c21)
          c22 = tax.get_tag(:c22)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 6 tags' do expect(taxonomy.size).to eq(6) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':a is root' do expect(a).to be_root end
          it ':a has no parent' do expect(a).to_not have_parent end
          it ':a has 3 children' do expect(a.children.size).to eq(3) end
          it ':b1 has 1 parent' do expect(b1.parents.size).to eq(1) end
          it ':b2 has 1 parent' do expect(b2.parents.size).to eq(1) end
          it ':b3 has 1 parent' do expect(b3.parents.size).to eq(1) end
          it ':b1 has no child' do expect(b1).to_not have_child end
          it ':b2 has 2 children' do expect(b2.children.size).to eq(2) end
          it ':b3 has no child' do expect(b3).to_not have_child end
          it ':c21 has parent' do expect(c21).to have_parent end
          it ':c21 has no child' do expect(c21).to_not have_child end
          it ':c22 has parent' do expect(c22).to have_parent end
          it ':c22 has no child' do expect(c22).to_not have_child end
        end
      end
    end
    describe 'double nested hierarchy with siblings' do
      ['[[:carp,:herring]<:fish,:insect]<:animal','[:insect,[:carp,:herring]<:fish]<:animal',':animal>[:insect,:fish>[:carp,:herring]]',':animal>[:fish>[:carp,:herring],:insect]'].each do |ddl|
        describe ddl do
          tax = Taxonomy.new
          tax.dag_prevent
          tax.instantiate(ddl)
          animal = tax.get_tag(:animal)
          fish = tax.get_tag(:fish)
          insect = tax.get_tag(:insect)
          carp = tax.get_tag(:carp)
          herring = tax.get_tag(:herring)
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          it 'taxonomy has 5 tags' do expect(taxonomy.size).to eq(5) end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':animal is root' do expect(animal).to be_root end
          it ':animal has no parent' do expect(animal).to_not have_parent end
          it ':animal has 2 children' do expect(animal.children.size).to eq(2) end
          it ':fish has 1 parent' do expect(fish.parents.size).to eq(1) end
          it ':fish has 2 children' do expect(fish.children.size).to eq(2) end
          it ':insect has 1 parent' do expect(insect.parents.size).to eq(1) end
          it ':insect has no child' do expect(insect).to_not have_child end
          it ':carp has 1 parent' do expect(carp.parents.size).to eq(1) end
          it ':carp has no child' do expect(carp).to_not have_child end
          it ':herring has 1 parent' do expect(herring.parents.size).to eq(1) end
          it ':herring has no child' do expect(herring).to_not have_child end
        end
      end
    end
    describe 'animal_taxonomy' do
      ['add_tags','instantiate'].each do |method|
        describe "#{method}" do
          tax = animal_taxonomy(method=='instantiate')
          taxonomy = tax.tags
          roots = tax.roots
          folks = tax.folksonomy
          animal = tax.get_tag(:animal)
          food = tax.get_tag(:food)
          it 'taxonomy has 11 tags' do expect(taxonomy.size).to eq(11) end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it 'has no folks' do expect(folks.size).to eq(0) end
          it ':animal is root' do expect(animal).to be_root end
          it ':food is root' do expect(food).to be_root end
        end
      end
    end
  end
end
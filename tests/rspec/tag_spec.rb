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
      @taxonomy = Tag.tags
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
      all_folks = Tag.tags.values.select {|tag| tag.folk?}
      @omitted_folks = (all_folks-Tag.folksonomy)
      @non_folks = (Tag.folksonomy-all_folks)
      @taxonomy = Tag.tags
    end
    it 'taxonomy has 11 tags' do expect(@taxonomy.size).to eq(11) end
    it 'includes all folks' do expect(@omitted_folks).to be_empty end
    it 'includes only folks' do expect(@non_folks).to be_empty end
  end
  context 'roots' do
    before(:all) do
      instantiate_animal_taxonomy
      all_roots = Tag.tags.values.select {|tag| tag.root?}
      @omitted_roots = (all_roots-Tag.roots)
      @non_roots = (Tag.roots-all_roots)
      @taxonomy = Tag.tags
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
  describe 'deletion integrity' do
    describe 'parent/child links' do
      describe ':b -x-> :a' do
        describe 'before' do
          Tag.empty
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':a is root' do expect(a).to be_root end
        end
        describe :delete_child do
          Tag.empty
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          a.delete_child(b)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(roots).to be_empty end
          it 'has 2 folksonomies' do expect(folks.size).to eq(2) end
        end
        describe :delete_parent do
          Tag.empty
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          b.delete_parent(a)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a has no child' do expect(a).to_not have_child end
          it ':b has no parent' do expect(b).to_not have_parent end
          it 'has no roots' do expect(roots).to be_empty end
          it 'has 2 folksonomies' do expect(folks.size).to eq(2) end
        end
      end
      context ':b -x-> :a -> :r' do
        context 'before' do
          Tag.empty
          Tag.add_tag(:a,:r)
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          r = Tag.get_tag(:r)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':r has child' do expect(r).to have_child end
          it ':a has child' do expect(a).to have_child end
          it ':a has parent' do expect(a).to have_parent end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':r is root' do expect(r).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          Tag.empty
          Tag.add_tag(:a,:r)
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          r = Tag.get_tag(:r)
          a.delete_child(b)
          roots = Tag.roots
          folks = Tag.folksonomy
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
          Tag.empty
          Tag.add_tag(:a,:r)
          Tag.add_tag(:b,:a)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          r = Tag.get_tag(:r)
          b.delete_parent(a)
          roots = Tag.roots
          folks = Tag.folksonomy
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
          Tag.empty
          Tag.add_tag(:b,:a)
          Tag.add_tag(:l,:b)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          l = Tag.get_tag(:l)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it ':b has child' do expect(b).to have_child end
          it ':l has parent' do expect(l).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          Tag.empty
          Tag.add_tag(:b,:a)
          Tag.add_tag(:l,:b)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          l = Tag.get_tag(:l)
          a.delete_child(b)
          roots = Tag.roots
          folks = Tag.folksonomy
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
          Tag.empty
          Tag.add_tag(:b,:a)
          Tag.add_tag(:l,:b)
          a = Tag.get_tag(:a)
          b = Tag.get_tag(:b)
          l = Tag.get_tag(:l)
          b.delete_parent(a)
          roots = Tag.roots
          folks = Tag.folksonomy
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
          Tag.empty
          Tag.add_tag(:b,:a1)
          Tag.add_tag(:b,:a2)
          a1 = Tag.get_tag(:a1)
          a2 = Tag.get_tag(:a2)
          b = Tag.get_tag(:b)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has child' do expect(a2).to have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 2 roots' do expect(roots.size).to eq(2) end
          it ':a1 is root' do expect(a1).to be_root end
          it ':a2 is root' do expect(a2).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          Tag.empty
          Tag.add_tag(:b,:a1)
          Tag.add_tag(:b,:a2)
          a1 = Tag.get_tag(:a1)
          a2 = Tag.get_tag(:a2)
          b = Tag.get_tag(:b)
          a2.delete_child(b)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a1 has child' do expect(a1).to have_child end
          it ':a2 has no child' do expect(a2).to_not have_child end
          it ':b has parent' do expect(b).to have_parent end
          it 'has 1 root' do expect(roots.size).to eq(1) end
          it ':a1 is root' do expect(a1).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':a2 is folk' do expect(a2).to be_folk end
        end
        context :delete_parent do
          Tag.empty
          Tag.add_tag(:b,:a1)
          Tag.add_tag(:b,:a2)
          a1 = Tag.get_tag(:a1)
          a2 = Tag.get_tag(:a2)
          b = Tag.get_tag(:b)
          b.delete_parent(a2)
          roots = Tag.roots
          folks = Tag.folksonomy
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
          Tag.empty
          Tag.add_tag(:b1,:a)
          Tag.add_tag(:b2,:a)
          b1 = Tag.get_tag(:b1)
          b2 = Tag.get_tag(:b2)
          a = Tag.get_tag(:a)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has parent' do expect(b2).to have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has no folks' do expect(folks).to be_empty end
        end
        context :delete_child do
          Tag.empty
          Tag.add_tag(:b1,:a)
          Tag.add_tag(:b2,:a)
          b1 = Tag.get_tag(:b1)
          b2 = Tag.get_tag(:b2)
          a = Tag.get_tag(:a)
          a.delete_child(b2)
          roots = Tag.roots
          folks = Tag.folksonomy
          it ':a has child' do expect(a).to have_child end
          it ':b1 has parent' do expect(b1).to have_parent end
          it ':b2 has no parent' do expect(b2).to_not have_parent end
          it 'has 1 roots' do expect(roots.size).to eq(1) end
          it ':a is root' do expect(a).to be_root end
          it 'has 1 folk' do expect(folks.size).to eq(1) end
          it ':b2 is folk' do expect(b2).to be_folk end
        end
        context :delete_parent do
          Tag.empty
          Tag.add_tag(:b1,:a)
          Tag.add_tag(:b2,:a)
          b1 = Tag.get_tag(:b1)
          b2 = Tag.get_tag(:b2)
          a = Tag.get_tag(:a)
          b2.delete_parent(a)
          roots = Tag.roots
          folks = Tag.folksonomy
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
  end
  context 'dag integrity' do
    context 'prevent recursion (:a <-+-> :a)' do
      [:dag_fix,:dag_prevent].each do |context|
        context context do
          Tag.empty
          Tag.send(context)
          Tag.add_tag(:animal,:animal)
          taxonomy = Tag.tags
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
        taxonomy = Tag.tags
        roots = Tag.roots
        folks = Tag.folksonomy
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
        taxonomy = Tag.tags
        roots = Tag.roots
        folks = Tag.folksonomy
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
        taxonomy = Tag.tags
        roots = Tag.roots
        folks = Tag.folksonomy
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
        taxonomy = Tag.tags
        roots = Tag.roots
        folks = Tag.folksonomy
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
end
class Tag
  @@tags = {}
  @@roots = []      # maintain
  @@folksonomy = [] # maintain

  def self.get_tags; @@tags end

  def self.get_tag(name) @@tags[name] end

  def self.has_tag?(name) @@tags.has_key?(name) end

  def self.delete_tag(name)
    # joins children to parents
    if Tag.has_tag?(name)
      tag = Tag.get_tag(name)
      parents = tag.parents.dup
      children = tag.children.dup
      if parents && children
        parents.each do |parent|
          parent.add_children(children)
          parent.delete_child(tag)
        end
        children.each do |child|
          child.add_parents(parents)
          child.delete_parent(tag)
        end
      end
      @@tags.delete(name)
    end
  end

  def self.add_tag(name, parent=nil)
    if Tag.has_tag?(name)
      new = false
      this = Tag.get_tag(name)
    else
      new = true
      this = Tag.new(name)
    end
    if parent.nil?
      Tag.add_folksonomy(this) if new
    else
      Tag.has_tag?(parent) ? tag_parent = Tag.get_tag(parent) : tag_parent = Tag.new(parent)
      this.add_parent(tag_parent)
    end
  end

  def self.subtract_tags(tags)
    tags.each {|tag| @@tags.delete(tag.name.to_sym)}
  end

  def self.get_roots; @@roots end

  def self.has_root?(tag) @@roots.include?(tag) end

  def self.delete_root(tag) @@roots.delete(tag) end

  def self.add_root(tag)
    @@roots += [tag] if !Tag.has_root?(tag)
  end

  def self.subtract_roots(tags) @@roots -= tags end

  def self.get_folksonomy; @@folksonomy end

  def self.has_folksonomy?(tag) @@folksonomy.include?(tag) end

  def self.delete_folksonomy(tag) @@folksonomy.delete(tag) end

  def self.add_folksonomy(tag)
    @@folksonomy += [tag] if !Tag.has_folksonomy?(tag)
  end

  def self.subtract_folksonomy(tags) @@folksonomy -= tags end

  def initialize(name)
    @name = name
    @parents = []
    @children = []
    @items = []     # to be supported
    @@tags[name] = self
  end

  def name; @name end

  def parents; @parents end

  def pp_parents
    a_p = []
    parents.each {|parent| a_p += [parent.name] }
    '['+a_p.join(', ')+']'
  end

  def has_parent?(tag=nil)
    if tag.nil?
      !parents.to_a.empty?
    else
      parents.include?(tag)
    end
  end

  def delete_parent(tag)
    if has_parent?(tag)
      @parents.delete(tag)
      tag.delete_child(self)
      if !tag.has_child? && !tag.has_parent?
        Tag.delete_root(self)
        Tag.add_folksonomy(self)
      end
    end
  end

  def add_parent(tag)
    if !has_parent?(tag)
      @parents += [tag]
      root = false
      if Tag.has_folksonomy?(tag)
        Tag.delete_folksonomy(tag)
        root = true
      end
      Tag.add_root(tag) if root || !tag.has_parent?
      Tag.delete_root(self)
      tag.add_child(self)
    end
  end

  def add_parents(parents) @parents |= parents.to_a end

  def children; @children end

  def pp_children
    a_p = []
    children.each {|child| a_p += [child.name] }
    '['+a_p.join(', ')+']'
  end

  def has_child?(tag=nil)
    if tag.nil?
      !children.to_a.empty?
    else
      children.include?(tag)
    end
  end

  def delete_child(tag)
    if has_child?(tag)
      @children.delete(tag)
      if @children.empty? && Tag.has_root?(tag)
        Tag.delete_root(tag)
        Tag.add_folksonomy(tag)
      end
    end
  end

  def empty_children; @child = [] end

  def add_child(tag)
    @children += [tag] if !has_child?(tag)
  end

  def add_children(children) @children |= children.to_a end

  def get_descendents(descendents=[])
    children.each {|child| descendents |= child.get_descendents(children)}
  end

  def delete_descendents
    descendents = get_descendents
    Tag.subtract_tags(descendents)
    Tag.subtract_roots(descendents)
    Tag.subtract_folksonomy(descendents)
    empty_children
  end

  def add_descendents(source_tag)
    children = source_tag.children
    add_children(children)
    root = false
    if Tag.has_folksonomy?(self)
      Tag.delete_folksonomy(self)
      root = true
    end
    Tag.add_root(self) if root || !has_parent?
    children.each {|child| child.add_parents([self])}
    # source_tag.children.each {|child| child.add_parent(self)
  end

  def delete_branch
    # delete self and its descendents
    delete_descendents
    parent.delete_child(self)
    @@tags.delete(name)
  end

  def inspect; "Tag<name=#{name}, parents=#{pp_parents}, children=#{pp_children}>" end
  def to_s; inspect end

end

require 'pp'
Tag.add_tag(:mouse,:animal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:cat, :mammal)
Tag.add_tag(:dog, :mammal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:mammal, :animal)
Tag.add_tag(:fish, :animal)
Tag.add_tag(:carp, :fish)
Tag.add_tag(:herring, :fish)
Tag.add_tag(:insect, :animal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:mouse).get_descendents}"
puts "descendents= #{Tag.get_tag(:mammal).get_descendents}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"
Tag.delete_tag(:mammal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"

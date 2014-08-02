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
          parent.add_children(children, true)
          parent.delete_child(tag)
        end
      end
      @@tags.delete(name)
    end
  end

  def self.add_tag(name, name_parent=nil)
    if Tag.has_tag?(name)
      new = false
      tag = Tag.get_tag(name)
    else
      new = true
      tag = Tag.new(name)
    end
    if name_parent.nil?
      Tag.add_folksonomy(tag) if new
    else
      Tag.has_tag?(name_parent) ? tag_parent = Tag.get_tag(name_parent) : tag_parent = Tag.new(name_parent)
      tag.add_parents([tag_parent],true)
    end
  end

  def self.subtract_tags(tags)
    tags.each {|tag| @@tags.delete(tag.name.to_sym)}
  end

  def self.get_roots; @@roots end

  def self.has_root?(tag) @@roots.include?(tag) end

  def self.delete_root(tag) @@roots.delete(tag) end

  def self.add_root(tag) @@roots |= [tag] end

  def self.subtract_roots(tags) @@roots -= tags.to_a end

  def self.get_folksonomy; @@folksonomy end

  def self.has_folksonomy?(tag) @@folksonomy.include?(tag) end

  def self.delete_folksonomy(tag) @@folksonomy.delete(tag) end

  def self.add_folksonomy(tag) @@folksonomy |= [tag] end

  def self.subtract_folksonomy(tags) @@folksonomy -= tags.to_a end

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

  def add_parents(tags, link=false)
    @parents |= tags.to_a
    if link
      register_child
      tags.each do |tag|
        tag.add_children([self])
        tag.register_parent
      end
    end
  end

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

  def add_children(tags, link=false)
    @children |= tags.to_a
    if link
      register_parent
      tags.each do |tag|
        tag.add_parents([self])
        tag.register_child
      end
    end
  end

  def empty_children; @child = [] end

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

  def add_descendents(source_tag) add_children(source_tag.children) end

  def delete_branch
    # delete self and its descendents
    delete_descendents
    parent.delete_child(self)
    @@tags.delete(name)
  end

  def register_parent
    Tag.delete_folksonomy(self) if Tag.has_folksonomy?(self)
    Tag.add_root(self) if !has_parent?
  end

  def register_child
    Tag.delete_folksonomy(self) if Tag.has_folksonomy?(self)
    Tag.delete_root(self) if Tag.has_root?(self)
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

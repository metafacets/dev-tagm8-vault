class Tag
  @@tags = {}
  @@roots = []      # maintain
  @@folksonomy = [] # maintain

  def self.get_tags; @@tags end

  def self.get_tag(name) @@tags[name] end

  def self.has_tag?(name) @@tags.has_key?(name) end

  def self.delete_tag(name) # redo
    if Tag.has_tag?(name)
      tag = Tag.get_tag(name)
      parents = tag.parents
      children = tag.children
      if parents && children
        parents.each do |parent|
          tag_parent = Tag.get_tag(parent)
          tag_parent.add_children(children)
          tag_parent.delete_child(name)
        end
        children.each do |child|
          tag_child = Tag.get_tag(child)
          tag_child.add_parents(parents)
          tag_child.delete_parent(name)
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
      Tag.add_folksonomy(name) if new
    else
      Tag.new(parent) if !Tag.has_tag?(parent)
      this.add_parent(parent)
    end
  end

  def self.get_roots; @@roots end

  def self.has_root?(name) @@roots.include?(name) end

  def self.delete_root(name) @@roots.delete(name) end

  def self.add_root(name)
    @@roots += [name] if !Tag.has_root?(name)
  end

  def self.get_folksonomy; @@folksonomy end

  def self.has_folksonomy?(name) @@folksonomy.include?(name) end

  def self.delete_folksonomy(name) @@folksonomy.delete(name) end

  def self.add_folksonomy(name)
    @@folksonomy += [name] if !Tag.has_folksonomy?(name)
  end

  def initialize(name)
    @name = name
    @parents = []
    @children = []
    @items = []     # support
    @@tags[name] = self
  end

  def name; @name end

  def parents; @parents end

  def has_parent?(parent=nil)
    if parent.nil?
      !parents.to_a.empty?
    else
      parents.include?(parent)
    end
  end

  def delete_parent(parent)
    if has_parent?(parent)
      @parents.delete(parent)
      tag_parent = Tag.get_tag(parent)
      tag_parent.delete_child(name)
      if !tag_parent.has_child? && !tag_parent.has_parent?
        Tag.delete_root(name)
        Tag.add_folksonomy(name)
      end
    end
  end

  def add_parent(parent)
    if !has_parent?(parent)
      @parents += [parent]
      root = false
      if Tag.has_folksonomy?(parent)
        Tag.delete_folksonomy(parent)
        root = true
      end
      Tag.add_root(parent) if root || !Tag.get_tag(parent).has_parent?
      Tag.delete_root(name)
      Tag.get_tag(parent).add_child(name)
    end
  end

  def add_parents(parents) @parents |= parents.to_a end

  def children; @children end

  def has_child?(child=nil)
    if child.nil?
      !children.to_a.empty?
    else
      children.include?(child)
    end
  end

  def delete_child(name)
    if has_child?(name)
      @children.delete(name)
      if @children.empty? && Tag.has_root?(name)
        Tag.delete_root(name)
        Tag.add_folksonomy(name)
      end
    end
  end

  def add_child(name)
    @children += [name] if !has_child?(name)
  end

  def add_children(children) @children |= children.to_a end

end

Tag.add_tag(:mouse,:animal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:cat, :mammal)
Tag.add_tag(:dog, :mammal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.add_tag(:mammal, :animal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
Tag.delete_tag(:mammal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"

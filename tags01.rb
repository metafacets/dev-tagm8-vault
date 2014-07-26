class Tag
  @@tags = {}
  @@roots = []      # maintain
  @@folksonomy = [] # maintain

  def self.get_tags
    @@tags
  end

  def self.get_roots
    @@roots
  end

  def self.has_root?(name)
    @@roots.include?(name)
  end

  def self.add_root(name)
    @@roots += [name] if !Tag.has_root?(name)
  end

  def self.delete_root(name)
    @@roots.delete(name)
  end

  def self.get_folksonomy
    @@folksonomy
  end

  def self.has_folksonomy?(name)
    @@folksonomy.include?(name)
  end

  def self.add_folksonomy(name)
    @@folksonomy += [name] if !Tag.has_folksonomy?(name)
  end

  def self.delete_folksonomy(name)
    @@folksonomy.delete(name)
  end

  def initialize(name)
    set_name(name)
    @parent = nil
    @child = []
    @items = []     # support
    @@tags[name] = self
  end

  def self.get_tag(name)
    @@tags[name]
  end

  def self.has_tag?(name)
    @@tags.has_key?(name)
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

  def has_parent?(parent=nil)
    if parent.nil?
      !@parent.nil?
    else
      @parent == parent
    end
  end

  def get_parent
    @parent
  end

  def set_parent(parent)
    @parent = parent
    root = false
    if Tag.has_folksonomy?(parent)
      Tag.delete_folksonomy(parent)
      root = true
    end
    Tag.add_root(parent) if root || !Tag.get_tag(parent).has_parent?
    Tag.delete_root(get_name)
  end

  def has_child?(child=nil)
    if child.nil?
      !@child.to_a.empty?
    else
      @child.include?(child)
    end
  end

  def get_children
    @child
  end

  def get_name
    @name
  end

  def set_name(name)
    @name = name
  end

  def add_parent(parent)
    if has_parent?
      if !has_parent?(parent)
        tag_parent = Tag.get_tag(get_parent)
        tag_parent.delete_child(get_name)
        set_parent(parent)
        Tag.get_tag(parent).add_child(get_name)
      end
    else
      set_parent(parent)
      Tag.get_tag(parent).add_child(get_name)
    end
  end

  def delete_parent
    @parent = nil
  end

  def add_child(name)
    @child += [name] if !has_child?(name)
  end

  def add_children(children)
    @child += children
  end

  def delete_child(name)
    if has_child?(name)
      @child.delete(name)
      if @child.empty? && Tag.has_root?(get_name)
        Tag.delete_root(get_name)
        Tag.add_folksonomy(name)
      end
    end
  end

  def self.delete_tag(name)
    if Tag.has_tag?(name)
      tag = Tag.get_tag(name)
      parent = tag.get_parent
      children = tag.get_children
      # puts tag.get_children, parent
      children.each do |child|
        # puts child
        tag_child = Tag.get_tag(child)
        tag_child.set_parent(parent)
      end
      if !parent.nil?
        tag_parent = Tag.get_tag(parent)
        tag_parent.add_children(children)
        tag_parent.delete_child(name)
      end
      @@tags.delete(name)
    end
  end
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

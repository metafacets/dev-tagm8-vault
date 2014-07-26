class Tag
  @@tags = {}
  @@roots = []      # maintain
  @@folksonomy = [] # maintain

  def self.get_tags
    @@tags
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
    this = Tag.has_tag?(name) ? Tag.get_tag(name) : Tag.new(name)
    if !parent.nil?
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
        Tag.get_tag(get_parent).delete_child(get_name)
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
    @child.delete(name) if has_child?(name)
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
puts Tag.get_tags
Tag.add_tag(:cat, :mammal)
Tag.add_tag(:dog, :mammal)
Tag.add_tag(:mammal, :animal)
puts Tag.get_tags
Tag.delete_tag(:mammal)
puts Tag.get_tags

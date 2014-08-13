class Tag
  def self.empty?; !Tag.has_tag? && !Tag.has_root? && !Tag.has_folksonomy? end

  def self.empty
    @@tags = {}
    @@roots = []      # maintain
    @@folksonomy = [] # maintain
  end

  Tag.empty

  def self.get_tags; @@tags end

  def self.get_tag(name) @@tags[name] end

  def self.has_tag?(name=nil)
    if name.nil?
      !@@tags.empty?
    else
      @@tags.has_key?(name)
    end
  end

  def self.delete_tag(name)
    # deletes tag by name joining its children to its parents
    if Tag.has_tag?(name)
      tag = Tag.get_tag(name)
      parents = tag.parents.dup
      children = tag.children.dup
      parents.each do |parent|
        parent.add_children(children, true) if children
        parent.delete_child(tag)
      end
      children.each {|child| child.delete_parent(tag)}
      @@tags.delete(name)
    end
  end

  def self.add_tags(names, name_parent=nil)
    tags = names.map {|name| Tag.get_lazy_tag(name)}.uniq
    Tag.get_lazy_tag(name_parent).add_children(tags,true,true) if !name_parent.nil?
  end

  def self.add_tag(name, name_parent=nil) Tag.add_tags([name],name_parent) end

  def self.get_lazy_tag(node)
    case
      when node.class == 'Tag'
        node
      when Tag.has_tag?(node)
        Tag.get_tag(node)
      else
        Tag.new(node)
    end
  end

  def self.subtract_tags(tags)
    tags.each {|tag| @@tags.delete(tag.name.to_sym)}
  end

  def self.get_roots; @@roots end

  def self.has_root?(tag=nil)
    if tag.nil?
      !@@roots.empty?
    else
      @@roots.include?(tag)
    end
  end

  def self.delete_root(tag) @@roots.delete(tag) end

  def self.add_root(tag) @@roots |= [tag] end

  def self.subtract_roots(tags) @@roots -= tags.to_a end

  def self.get_folksonomy; @@folksonomy end

  def self.has_folksonomy?(tag=nil)
    if tag.nil?
      !@@folksonomy.empty?
    else
      @@folksonomy.include?(tag)
    end
  end

  def self.delete_folksonomy(tag) @@folksonomy.delete(tag) end

  def self.add_folksonomy(tag) @@folksonomy |= [tag] end

  def self.subtract_folksonomy(tags) @@folksonomy -= tags.to_a end

  def initialize(name)
    @name = name
    @parents = []
    @children = []
    @items = []     # to be supported
    @@tags[name] = self
    Tag.add_folksonomy(self)
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
    puts "delete_parent 1: self=#{self}, tag=#{tag}"
    if has_parent?(tag)
      @parents.delete(tag)
      puts "delete_parent 2: self=#{self}"
      tag.delete_child(self)
      puts "delete_parent 3: self=#{self}, tag=#{tag}"
    end
  end

  def add_parents(tags, link=false, dag=false)
    # ensure_dag by breaking loops on parent
    if !tags.to_a.empty?
      if link
        descendents = get_descendents if dag
        tags.each do |tag|
          puts "add_parents 1: name=#{name}, parent=#{tag.name}"
          tag.ensure_dag(descendents) if dag && descendents.include?(tag)
          tag.add_children([self])
          puts "add_parents 2: self=#{tag}"
          tag.register_parent
          puts "add_parents 3: Roots = #{Tag.get_roots}, Folks = #{Tag.get_folksonomy}"
        end
      end
      @parents |= tags.to_a
      register_child if link
      puts "add_parents 4: Roots = #{Tag.get_roots}, Folks = #{Tag.get_folksonomy}"
    end
  end

  def add_children(tags, link=false, dag=false)
    # ensure_dag by breaking loops on self
    if !tags.to_a.empty?
      if link
        ancestors = get_ancestors if dag
        tags.each do |tag|
          puts "add_children 1: name=#{tag.name}, parent=#{name}"
          ensure_dag(tag.get_descendents) if dag && ancestors.include?(tag)
          tag.add_parents([self])
          tag.register_child
        end
      end
      @children |= tags.to_a
      register_parent if link
    end
  end

  def ensure_dag(descendents)
    # maintains directed acyclic graph by removing self from all descendents
    puts "ensure_dag: self=#{self}, descendents=#{descendents}"
    (parents & descendents).each {|parent| delete_parent(parent)}
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
      if !has_child? && Tag.has_root?(self)
        Tag.delete_root(self)
        Tag.add_folksonomy(self)
      end
      if !tag.has_parent?
        if tag.has_child?
          Tag.add_root(tag)
        else
          Tag.add_folksonomy(tag)
        end
      end
    end
  end

  def empty_children; @child = [] end

  def get_ancestors(ancestors=[])
    parents.each {|parent| ancestors |= parent.get_ancestors(parents)}
    ancestors
  end

  def get_depth(root,branch)
    # walks up branch from self to root returning depth
    # dag support requirs nodes outside branch are ignored
    if parents.include?(root)
      depth = 1
    else
      parent = (parents & branch).pop
      parent.nil? ? depth = 0 : depth = parent.get_depth(root,branch) + 1
    end
    depth
  end

  def get_descendents(descendents=[])
    children.each {|child| descendents |= child.get_descendents(children)}
    descendents
  end

  def get_descendents1(descendents=[])
    # alternative to get_descendents
    children.each {|child| descendents |= child.get_descendents}
    descendents |= children
  end

  def delete_descendents
    descendents = get_descendents
    Tag.subtract_tags(descendents)
    Tag.subtract_roots(descendents)
    Tag.subtract_folksonomy(descendents)
    empty_children
  end

  def add_descendents(child_tags) add_children(child_tags, true, true) end

  def delete_branch
    # delete self and its descendents
    delete_descendents
    parent.delete_child(self)
    @@tags.delete(name)
  end

  def add_branch(tag)
    # if self is root add tag as new root else add tag as sibling of self
  end

  def register_parent
    if has_child?
      Tag.delete_folksonomy(self) if Tag.has_folksonomy?(self)
      Tag.add_root(self) if !has_parent?
    end
  end

  def register_child
    if has_parent?
      Tag.delete_folksonomy(self) if Tag.has_folksonomy?(self)
      Tag.delete_root(self) if Tag.has_root?(self)
    end
  end

  def inspect; "Tag<name=#{name}, parents=#{pp_parents}, children=#{pp_children}>" end
  def to_s; inspect end

  # methods added for rspec readability
  def folk?; !has_parent? && !has_child? end
  def root?; !has_parent? && has_child? end

end


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
      parents.each do |parent|
        parent.add_children(children, true) if children
        parent.delete_child(tag)
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

  def add_parents(tags, link=false, dag=false)
    # check to ensure DAG
    if tags
      @parents += tags.to_a
      if link
        register_child
        descendents = get_descendents if dag
        tags.each do |tag|
          tag.add_children([self])
          tag.register_parent
          if dag
            loopers = []
            loops = tag.get_ancestors & descendents
            loops.each {|loop| loopers << [[loop.get_depth(self,descendents),loop]]}
            loopers.sort_by{|x|x[0]}.reverse.each do |looper|
              looper[1].delete_parent(looper[1].get_parents & descendents)
            end
          end
        end
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
    # check to ensure DAG
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

  def add_descendents(child_tags) add_children(child_tags, true) end

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
Tag.add_tag(:carp, :food)
Tag.add_tag(:carpette, :carp)
Tag.add_tag(:herring, :fish)
Tag.add_tag(:insect, :animal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:mouse).get_descendents}"
puts "descendents= #{Tag.get_tag(:mammal).get_descendents}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"
puts "ancestors= #{Tag.get_tag(:carpette).get_ancestors}"
puts "depth= #{Tag.get_tag(:carpette).get_depth(Tag.get_tag(:fish),Tag.get_tag(:fish).get_descendents)}"
Tag.delete_tag(:mammal)
puts "Tags = #{Tag.get_tags}", "Roots = #{Tag.get_roots}", "Folks = #{Tag.get_folksonomy}"
puts "descendents= #{Tag.get_tag(:animal).get_descendents}"

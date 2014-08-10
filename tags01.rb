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
    # joins children to parents
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
      tag.add_parents([tag_parent],true,true)
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
      if !tag.has_child? && !tag.has_parent?
        Tag.delete_root(self)
        Tag.add_folksonomy(self)
        puts "delete_parent 4: self=#{self}, tag=#{tag}"
      end
    end
  end

  def add_parents(tags, link=false, dag=false)
    # check to ensure DAG
    if !tags.to_a.empty?
      if link
        descendents = get_descendents if dag
        tags.each do |tag|
          ancestors = get_ancestors
          ancestors |= [tag]
          puts "add_parents 1: name=#{name}, parent=#{tag.name}"
          ensure_dag(descendents,ancestors) if dag
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
    # check to ensure DAG
    if !tags.to_a.empty?
      if link
        ancestors = get_ancestors if dag
        tags.each do |tag|
          descendents = get_descendents
          descendents |= [tag]
          ensure_dag(descendents, ancestors) if dag
          tag.add_parents([self])
          tag.register_child
        end
      end
      @children |= tags.to_a
      register_parent if link
    end
    #@children |= tags.to_a
    #if link
    #  register_parent
    #  ancestors = get_ancestors if dag
    #  tags.each do |tag|
    #    tag.add_parents([self])
    #    tag.register_child
    #    tag.ensure_dag(tag.get_descendents, ancestors) if dag
    #  end
    #end
  end

  def ensure_dag(descendents,ancestors)
    # maintains directed acyclic graph by removing occurances of ancestors among descendents
    # specifically by deleting that occurence parent which causes it to be a descendant
    loops = descendents & ancestors
    puts "ensure_dag: loops=#{loops}, self=#{self}, descendents=#{descendents}, ancestors=#{ancestors}"
    if !loops.empty?
      loopers = []
      loops.each {|loop| loopers << [loop.get_depth(self,descendents),loop]}
      puts "ensure_dag: loopers=#{loopers}, loopers.sort_by{|x|x[0]}.reverse= #{loopers.sort_by{|x|x[0]}.reverse}"
      loopers.sort_by{|x|x[0]}.reverse.each do |looper|
        puts "ensure_dag: looper=#{looper}, looper[1]=#{looper[1]}, looper[1].parents&desc=#{looper[1].parents & descendents}"
        looper[1].delete_parent((looper[1].parents & descendents).pop)
        puts "ensure_dag: looper[1]=#{looper[1]}"
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

end


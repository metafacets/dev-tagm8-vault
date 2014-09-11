require_relative 'debug.rb'
#Debug.new(class:'Tag',method:'ensure_dag') # comment out to turn off
class Tag
  def self.empty?; !Tag.has_tag? && !Tag.has_root? && !Tag.has_folksonomy? end

  def self.tags=(tags) @@tags = tags end

  def self.roots=(roots) @@roots = roots end

  def self.folksonomy=(folks) @@folksonomy = folks end

  def self.dag=(dag=false)
    unless dag || (dag.is_a? String && (dag == 'prevent' || dag == 'fix'))
      @@dag = false
    else
      @@dag = dag
    end
  end

  def self.dag_prevent; Tag.dag = 'prevent' end

  def self.dag_fix; Tag.dag = 'fix' end

  def self.dag; @@dag end

  def self.dag?; !!Tag.dag end

  def self.dag_prevent?; Tag.dag == 'prevent' end

  def self.dag_fix?; Tag.dag == 'fix' end

  def self.empty
    Tag.tags = {}
    Tag.roots = []
    Tag.folksonomy = []
    Tag.dag_prevent
  end

  Tag.empty


  def self.tags; @@tags end

  def self.get_tag(name) Tag.tags[name] end

  def self.has_tag?(name=nil)
    if name.nil?
      !Tag.tags.empty?
    else
      Tag.tags.has_key?(name)
    end
  end

  def self.delete_tag(name)
    if Tag.has_tag?(name)
      tag = Tag.get_tag(name)
      parents = tag.parents.dup
      children = tag.children.dup
      Tag.tags.delete(name)
      Tag.update_status(parents|children|[tag])
    end
  end

  def self.instantiate(tag_ddl)
    tag_ddl[">"] = ",'>'," if tag_ddl.include?('>')
    tag_ddl = '['+tag_ddl+']' unless /^\[.*\]$/.match(tag_ddl)
    Tag.instantiate1(eval(tag_ddl))
  end

  def self.instantiate1(tags)
    puts "instantiate 1: tags=#{tags}"
    do_status = lambda {|stack|
      puts "do_status 1: stack=#{stack}"
      new = []
      stack.each {|i| new |= i}
      Tag.update_status(new)
    }
    stack = []
    link = false
    tags.reverse.each do |tag|
      puts "instantiate 2: tag=#{tag}, tag.class=#{tag.class}, stack=#{stack}"
      if tag.is_a? Array
        stack << Tag.instantiate1(tag)
      elsif tag == '>'
        link = true
      elsif tag.is_a? String
        stack << [Tag.get_lazy_tag(tag.to_sym)]
      elsif tag.is_a? Symbol
        stack << [Tag.get_lazy_tag(tag)]
      end
      puts "instantiate 3: tag=#{tag}, stack=#{stack}"
      if link && tag != '>' && stack.size > 1
        parents = stack.pop
        children = stack.pop
        Tag.link(children,parents)
        link = false
        do_status.call(stack) unless stack.empty?
        stack = [parents]
      end
    end
    do_status.call(stack)
    results = []
    stack.each {|i| results |= i}
    puts "instantiate 4: results=#{results}"
    results
  end

  def self.add_tags(names_children, name_parent=nil)
    children = names_children.map {|name| Tag.get_lazy_tag(name)}.uniq
    Tag.link(children,[Tag.get_lazy_tag(name_parent)]) unless name_parent.nil?
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
    tags.each {|tag| Tag.tags.delete(tag.name.to_sym)}
  end

  def self.roots; @@roots end

  def self.has_root?(tag=nil)
    if tag.nil?
      !Tag.roots.empty?
    else
      Tag.roots.include?(tag)
    end
  end

  def self.delete_root(tag) Tag.roots.delete(tag) end

  def self.add_root(tag) Tag.roots |= [tag] end

  def self.subtract_roots(tags) Tag.roots -= tags.to_a end

  def self.folksonomy; @@folksonomy end

  def self.has_folksonomy?(tag=nil)
    if tag.nil?
      !Tag.folksonomy.empty?
    else
      Tag.folksonomy.include?(tag)
    end
  end

  def self.delete_folksonomy(tag) Tag.folksonomy.delete(tag) end

  def self.add_folksonomy(tag) Tag.folksonomy |= [tag] end

  def self.subtract_folksonomy(tags) Tag.folksonomy -= tags.to_a end

  def self.update_status(tags)
    this_status = lambda {|tag|
      if tag.has_parent?
        Tag.delete_root(tag) if Tag.has_root?(tag)
        Tag.delete_folksonomy(tag) if Tag.has_folksonomy?(tag)
      else
        if tag.has_child?
          Tag.add_root(tag)
          Tag.delete_folksonomy(tag) if Tag.has_folksonomy?(tag)
        else
          Tag.add_folksonomy(tag)
          Tag.delete_root(tag) if Tag.has_root?(tag)
        end
      end
    }
    tags.each {|tag| this_status.call(tag)}
  end

  def self.link(children,parents)
    link_children = lambda {|children,parent|
      children -= [parent]
      unless children.empty?
        ctags = children.clone
        ancestors = parent.get_ancestors if Tag.dag?
        children.each do |child|
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['name',child.name],['parent',name]])
          if Tag.dag? && ancestors.include?(child)
            if Tag.dag_prevent?
              ctags -= [child]
            else
              (parent.parents & child.get_descendents+[child]).each {|grand_parent| parent.delete_parent(grand_parent)}
              child.parents |= [parent]
            end
          else
            child.parents |= [parent]
          end
        end
        parent.children |= ctags
      end
    }
    parents = parents.uniq
    children = children.uniq
    parents.each {|parent| link_children.call(children,parent)}
    Tag.update_status(parents|children)
  end

  def initialize(name)
    @name = name
    @parents = []
    @children = []
    @items = []     # to be supported
    Tag.tags[name] = self
    Tag.add_folksonomy(self)
  end

  def name; @name end

  def parents; @parents end

  def parents=(parents) @parents = parents end

  def has_parent?(tag=nil)
    if tag.nil?
      !parents.to_a.empty?
    else
      parents.include?(tag)
    end
  end

  def delete_parent(parent) parent.delete_child(self) end

  def add_parents(parents); Tag.link([self],parents) end

  def children; @children end

  def children=(children) @children = children end

  def has_child?(tag=nil)
    if tag.nil?
      !children.to_a.empty?
    else
      children.include?(tag)
    end
  end

  def delete_child(child)
    if has_child?(child)
      children.delete(child)
      child.parents.delete(self)
      Tag.update_status([self,child])
    end
  end

  def add_children(children); Tag.link(children,[self]) end

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

  def delete_descendents
    descendents = get_descendents
    Tag.subtract_tags(descendents)
    Tag.subtract_roots(descendents)
    Tag.subtract_folksonomy(descendents)
    empty_children
  end

  def add_descendents(children) add_children(children) end

  def delete_branch
    # delete self and its descendents
    delete_descendents
    parent.delete_child(self)
    Tag.tags.delete(name)
  end

  def add_branch(tag)
    # if self is root add tag as new root else add tag as sibling of self
  end

  def inspect
    pretty_print = lambda {|method|
      a_p = []
      send(method).each {|tag| a_p += [tag.name] }
      '['+a_p.join(', ')+']'
    }
    "Tag<name=#{name}, parents=#{pretty_print.call(:parents)}, children=#{pretty_print.call(:children)}>"
  end
  def to_s; inspect end

  # methods added for rspec readability
  def folk?; !has_parent? && !has_child? end
  def root?; !has_parent? && has_child? end

end


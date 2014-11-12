require_relative 'debug'
require_relative 'ddl'
require_relative 'query'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Taxonomy

  def initialize(name='taxonomy')
    @name = name
    empty
  end

  def name=(name) @name = name end
  def name; @name end
  def empty?; !has_tag? && !has_root? && !has_folksonomy? end

  def empty
    @tags = {}
    @roots = []
    @folksonomy = []
    dag_prevent
  end

  def dag=(dag=false)
    unless dag || (dag.is_a? String && (dag == 'prevent' || dag == 'fix'))
      @dag = false
    else
      @dag = dag
    end
  end

  def dag_prevent; @dag = 'prevent' end
  def dag_fix; @dag = 'fix' end
  def dag; @dag end
  def dag?; !!dag end
  def dag_prevent?; dag == 'prevent' end
  def dag_fix?; dag == 'fix' end
  def tags; @tags end
  def get_tag(name) tags[name] end

  def has_tag?(name=nil)
    if name.nil?
      !tags.empty?
    else
      tags.has_key?(name)
    end
  end

  def delete_tag(name)
    if has_tag?(name)
      tag = get_tag(name)
      parents = tag.parents
      children = tag.children
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tag',tag],['parents',parents],['children',children]])
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tags',tags],['roots',roots],['folks',folksonomy]])
      parents.each do |parent|
        parent.children -= [tag]
        parent.children |= children
      end
      children.each do |child|
        child.parents -= [tag]
        child.parents |= parents
      end
      tag.items.each {|item| item.tags -= [tag]}
      subtract_tags([tag])
      subtract_roots([tag])
      subtract_folksonomy([tag])
      update_status(parents|children)
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['tags',tags],['roots',roots],['folks',folksonomy]])
    end
  end

  def instantiate(tag_ddl)
    leaves = []
    Ddl.parse(tag_ddl)
    if Ddl.has_tags?
      tags = Ddl.tags.map {|name| get_lazy_tag(name)}
      leaves = Ddl.leaves.map {|name| get_lazy_tag(name)}
      Ddl.links.each do |pair|
        [0,1].each do |i|
          pair[i] = pair[i].map {|name| get_lazy_tag(name)}
        end
        link(pair[0],pair[1],false)
      end
      update_status(tags)
    end
    leaves
  end

  def deprecate(tag_ddl)
    Ddl.parse(tag_ddl)
    tags = Ddl.tags.map {|name| get_lazy_tag(name)}
    Ddl.tags.each {|name| delete_tag(name)} if Ddl.has_tags?
    tags
  end

  def query_items(query)
    Query.taxonomy = self
    begin
      eval(Query.parse(query))
    rescue SyntaxError
      []
    end
  end

  def add_tags(names_children, name_parent=nil)
    children = names_children.map {|name| get_lazy_tag(name)}.uniq
    link(children,[get_lazy_tag(name_parent)]) unless name_parent.nil?
  end

  def add_tag(name, name_parent=nil) add_tags([name],name_parent) end

  def get_lazy_tag(node)
    case
      when node.class == 'Tag'
        node
      when has_tag?(node)
        get_tag(node)
      else
        Tag.new(node,self)
    end
  end

  def subtract_tags(tags_to_delete)
    tags_to_delete.each {|tag| tags.delete(tag.name.to_sym)}
  end

  def roots; @roots end

  def has_root?(tag=nil)
    if tag.nil?
      !roots.empty?
    else
      roots.include?(tag)
    end
  end

  def add_roots(tags) @roots |= tags.to_a end

  def subtract_roots(tags) @roots -= tags.to_a end

  def folksonomy; @folksonomy end

  def has_folksonomy?(tag=nil)
    if tag.nil?
      !folksonomy.empty?
    else
      folksonomy.include?(tag)
    end
  end

  def add_folksonomy(tags) @folksonomy |= tags.to_a end

  def subtract_folksonomy(tags) @folksonomy -= tags.to_a end

  def update_status(tags)
    this_status = lambda {|tag|
      if tag.has_parent?
        subtract_roots([tag])
        subtract_folksonomy([tag])
      else
        if tag.has_child?
          add_roots([tag])
          subtract_folksonomy([tag])
        else
          add_folksonomy([tag])
          subtract_roots([tag])
        end
      end
    }
    tags.each {|tag| this_status.call(tag)}
  end

  def link(children,parents,status=true)
    link_children = lambda {|children,parent|
      children -= [parent]
      unless children.empty?
        ctags = children.clone
        ancestors = parent.get_ancestors if dag?
        children.each do |child|
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['name',child.name],['parent',name]])
          if dag? && ancestors.include?(child)
            if dag_prevent?
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
    update_status(parents|children) if status
  end
end

class Tag
  def initialize(name,taxonomy)
    @taxonomy = taxonomy
    @name = name
    @parents = []
    @children = []
    @items = []     # to be supported
    taxonomy.tags[name] = self
    taxonomy.add_folksonomy([self])
  end

  def taxonomy; @taxonomy end

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
      taxonomy.update_status([self,child])
    end
  end

  def add_children(children); taxonomy.link(children,[self]) end

  def empty_children; @child = [] end

  def items; @items end

  def items=(items) @items = items end

  def get_ancestors(ancestors=[])
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['self',self],['ancestors',ancestors]])
    parents.each {|parent| ancestors |= parent.get_ancestors(parents)}
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['ancestors',ancestors]])
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
    taxonomy.subtract_tags(descendents)
    taxonomy.subtract_roots(descendents)
    taxonomy.subtract_folksonomy(descendents)
    empty_children
  end

  def add_descendents(children) add_children(children) end

  def delete_branch
    # delete self and its descendents
    delete_descendents
    parent.delete_child(self)
    taxonomy.subtract_tags([self])
  end

  def add_branch(tag)
    # if self is root add tag as new root else add tag as sibling of self
  end

  def query_items
    # queries items matching this tag
    result = items
    get_descendents.each {|desc| result |= desc.items}
    result
  end

  def inspect
    pretty_link = lambda {|method|
      a_p = []
      send(method).each {|tag| a_p += [tag.name] }
      '['+a_p.join(', ')+']'
    }
    items.empty? ? pretty_items = '' : pretty_items = ", items=#{items.map {|item| item.name}}"
    "Tag<name=#{name}, parents=#{pretty_link.call(:parents)}, children=#{pretty_link.call(:children)}#{pretty_items}>"
  end
  def to_s; inspect end

  # methods added for rspec readability
  def folk?; !has_parent? && !has_child? end
  def root?; !has_parent? && has_child? end

end


require_relative 'debug'
require_relative 'ddl'
require_relative 'query'
require_relative '../../src/model/mongo_mapper_db'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Taxonomy < PTaxonomy

  def initialize(name='taxonomy')
    super(name:name)
    empty
    save
  end

  def empty?; !has_tag? && !has_root? && !has_folksonomy? end

  def empty
    dag_prevent
    save
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

  def delete_tag(name)
    if has_tag?(name)
      puts "Taxonomy.delete_tag: name=#{name}"
      tag = get_tag_by_name(name)
      puts "Taxonomy.delete_tag: tag=#{tag}"
      parents = tag.get_parents
      children = tag.get_children
      puts "Taxonomy.delete_tag: parents=#{parents}, children=#{children}"
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tag',tag],['parents',parents],['children',children]])
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['tags',tags],['roots',roots],['folks',folksonomy]])
      parents.each do |parent|
        #parent.children -= [tag]
        parent.pull(children:tag._id.to_s)
        #parent.children |= children
        children.each{|child| parent.add_to_set(children:child._id.to_s)}
      end
      children.each do |child|
        #child.parents -= [tag]
        child.pull(parents:tag._id.to_s)
        #child.parents |= parents
        parents.each{|parent| child.add_to_set(parents:parent._id.to_s)}
      end
      tag.items.each {|item| item.tags -= [tag]}
      puts "Taxonomy.delete_tag: tag_count=#{tag_count}, tags=#{tags}"
      subtract_tags([tag])
      puts "Taxonomy.delete_tag: tag_count=#{tag_count}, tags=#{tags}"
      #puts "Taxonomy.delete_tag: parents=#{parents}"
      #puts "Taxonomy.delete_tag: children=#{children}"
      #subtract_roots([tag])
      #subtract_folksonomies([tag])
      puts "Taxonomy.delete_tag: parents|children=#{parents|children}"
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
        get_tag_by_name(node)
      else
        Tag.new(node,self)
    end
  end

  # def roots; @roots end

  # def folksonomy; @folksonomy end

end

class Tag < PTag
  def initialize(name,tax)
    super(name:name,is_root:false,is_folk:true,taxonomy:tax._id)
    save
  end

  def delete_parent(parent)
    puts "Tag.delete_parent: self=#{self}, parent=#{parent}"
    parent.delete_child(self)
  end

  def add_parents(parents); taxonomy.link([self],parents) end

  def add_children(children); taxonomy.link(children,[self]) end

  def empty_children; @children = [] end

  def get_ancestors(ancestors=[])
    puts "Tag.get_ancestors: ancestors=#{ancestors}"
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['self',self],['ancestors',ancestors]])
    parnts = get_parents
    parnts.each {|parent| ancestors |= parent.get_ancestors(parnts)}
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
    puts "Tag.get_descendents: descendents=#{descendents}"
    childs = get_children
    childs.each {|child| descendents |= child.get_descendents(childs)}
    descendents
  end

  def delete_descendents
    descendents = get_descendents
    taxonomy.subtract_tags(descendents)
    taxonomy.subtract_roots(descendents)
    taxonomy.subtract_folksonomies(descendents)
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
    items.empty? ? pretty_items = '' : pretty_items = ", items=#{items.map {|item| item.name}}"
    #"Tag<_id=#{_id}, name=#{name}, tax=#{taxonomy}, parents=#{get_taxonomy.get_names_by_id(parents)}, children=#{get_taxonomy.get_names_by_id(children)}#{pretty_items}>"
    "Tag<#{name}: parents=#{get_taxonomy.get_names_by_id(parents)}, children=#{get_taxonomy.get_names_by_id(children)}#{pretty_items}>"
  end
  def to_s; inspect end

  # methods added for rspec readability
  def folk?; !has_parent? && !has_child? end
  def root?; !has_parent? && has_child? end

end


require 'active_support'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'tagm8'
MongoMapper.connection.drop_database('tagm8')

class PTaxonomy
  include MongoMapper::Document
  key :name, String
#  key :dag, Boolean
  many :tags, :class_name => 'PTag'

  def get_names_by_id(ids)
    names = []
    ids.each do |id|
      tag = PTag.first(_id:id.to_s)
      names << tag.name unless tag.nil?
    end
    names
  end

  def get_tag(id)
    PTag.first(_id:id.to_s)
  end

  def get_tags(ids)
    ids.map{|id| PTag.first(_id:id.to_s)}
  end

  def get_tag_by_name(name)
    PTag.first(taxonomy:self._id.to_s,name:name)
  end

  def tags
    PTag.where(taxonomy:self._id.to_s).all
  end

  def tag_count
    PTag.where(taxonomy:self._id.to_s).count
  end

  def has_tag?(name=nil)
    tags = tag_count
    if tags < 1
      false
    elsif name.nil?
      tags > 0
    else
      PTag.where(taxonomy:self._id.to_s,name:name.to_s).count > 0
    end
  end

  def subtract_tags(tags_to_delete)
    tags_to_delete.each {|tag| tag.delete}
  end

  def roots
    PTag.where(taxonomy:self._id.to_s,is_root:true).all
  end

  def root_count
    PTag.where(taxonomy:self._id.to_s,is_root:true).count
  end

  def has_root?(tag=nil)
    roots = root_count
    if roots < 1
      false
    elsif tag.nil?
      roots > 0
    else
      PTag.where(taxonomy:self._id.to_s,_id:tag._id.to_s,is_root:true).count > 0
    end
  end

  def add_roots(roots_to_add)
    roots_to_add.each{|tag| tag.is_root = true}
  end

  def subtract_roots(roots_to_delete)
    roots_to_delete.each{|tag| tag.is_root = false}
  end

  def folksonomies
    PTag.where(taxonomy:self._id.to_s,is_folk:true).all
  end

  def folksonomy; folksonomies end

  def folksonomy_count
    PTag.where(taxonomy:self._id.to_s,is_folk:true).count
  end

  def has_folksonomy?(tag=nil)
    folks = folksonomy_count
    if folks < 1
      false
    elsif tag.nil?
      folks > 0
    else
      PTag.where(taxonomy:self._id.to_s,_id:tag._id.to_s,is_folk:true).count > 0
    end
  end

  def add_folksonomies(folks_to_add)
    folks_to_add.each{|tag| tag.is_folksonomy = true}
  end

  def subtract_folksonomies(folks_to_delete)
    folks_to_delete.each{|tag| tag.is_folksonomy = false}
  end

  def update_status(tags)
    this_status = lambda {|tag|
      #puts "PTaxonomy.update_status: tag=#{tag}, tag.has_parent?=#{tag.has_parent?}, tag.has_child?=#{tag.has_child?}"
      if tag.has_parent?
        tag.set(is_root:false,is_folk:false)
      else
        if tag.has_child?
          tag.set(is_root:true,is_folk:false)
        else
          tag.set(is_folk:true,is_root:false)
        end
      end
    }
    tags.each {|tag| this_status.call(tag)}
  end

  def link(children,parents,status=true)
    link_children = lambda {|children,parent|
      #puts "PTaxonomy.link.link_children: parent=#{parent}"
      children -= [parent]
      unless children.empty?
        ctags = children.clone
        ancestors = parent.get_ancestors if dag?
        children.each do |child|
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['name',child.name],['parent',name]])
          if dag? && ancestors.include?(child)
            #puts "PTaxonomy.link.link_children: child=#{child}, ancestors=#{ancestors}, dag_prevent?=#{dag_prevent?}"
            if dag_prevent?
              ctags -= [child]
            else
              (parent.get_parents & child.get_descendents+[child]).each {|grand_parent| parent.delete_parent(grand_parent)}
              child.add_to_set(parents:parent._id.to_s)
              #child.parents |= [parent]
            end
          else
            child.add_to_set(parents:parent._id.to_s)
            #child.parents |= [parent]
          end
        end
        ctags.each{|ctag| parent.add_to_set(children:ctag._id.to_s)}
        #parent.children |= ctags
      end
    }
    parents = parents.uniq
    children = children.uniq
    #puts "PTaxonomy.link: parents=#{parents}, children=#{children}"
    parents.each {|parent| link_children.call(children,parent)}
    update_status(parents|children) if status
  end


end

class PTag
  include MongoMapper::Document
  key :name, String
  key :parents, Array
  key :children, Array
  key :items, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :taxonomy, String

  def get_taxonomy
    PTaxonomy.first(_id:taxonomy)
  end

  def get_parents
    parents.map{|id| PTag.first(_id:id.to_s)}
  end

  def has_parent?(tag=nil)
    tags = PTag.first(_id:_id.to_s).parents
    #puts "** Tag:has_parent? 1: parents=#{parents}, tags_by_name=#{get_taxonomy.get_names_by_id(tags)}, self.name=#{self.name}"
    if tag.nil?
      !tags.empty?
    else
      tags.include?(tag._id.to_s)
    end
  end

  def get_children
    children.map{|id| PTag.first(_id:id.to_s)}
  end

  def has_child?(tag=nil)
    tags = PTag.first(_id:_id.to_s).children
    #tags = children
    if tag.nil?
      !tags.empty?
    else
      tags.include?(tag._id.to_s)
    end
  end

  def delete_child(child)
    if has_child?(child)
      pull(children:child._id.to_s)
      child.pull(parents:_id.to_s)
      get_taxonomy.update_status([self,child])
    end
  end



end

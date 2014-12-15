require 'active_support'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'tagm8'
MongoMapper.connection.drop_database('tagm8')

class PTaxonomy
  include MongoMapper::Document
  key :name, String
  key :dag, String
  key :tag_ids, Array
  many :tags, :class_name => 'PTag', :in => :tag_ids
  many :albums, :class_name => 'PAlbum'

#  def get_names_by_id(ids)
#    names = []
#    ids.each do |id|
#      tag = PTag.first(_id:id.to_s)
#      names << tag.name unless tag.nil?
#    end
#    names
#  end

#  def get_tag(id)
#    PTag.first(_id:id.to_s)
#  end

#  def get_tags(ids)
#    ids.map{|id| PTag.first(_id:id.to_s)}
#  end

  def get_tag_by_name(name)
    puts "PTaxonomy.get_tag_by_name 1: name=#{name}"
    tag = PTag.first(taxonomy_id:self._id.to_s,name:name)
    puts "PTaxonomy.get_tag_by_name 2: tag._id=#{tag._id}, tag.name=#{tag.name}"
    tag
  end

#  def tags
#    PTag.where(taxonomy_id:self._id.to_s).all
#  end

  def tag_count(name=nil)
    if name.nil?
      PTag.where(taxonomy_id:self._id.to_s).count
    else
      PTag.where(taxonomy_id:self._id.to_s,name:name.to_s).count
    end
  end

  def subtract_tags(tags_to_delete)
    tags_to_delete.each {|tag| tag.delete}
#    self.tags -= tags_to_delete
#    save
  end

  def roots
    PTag.where(taxonomy_id:self._id.to_s,is_root:true).all
  end

  def root_count
    PTag.where(taxonomy_id:self._id.to_s,is_root:true).count
  end

  def has_root?(tag=nil)
    roots = root_count
    if roots < 1
      false
    elsif tag.nil?
      roots > 0
    else
      PTag.where(taxonomy_id:self._id.to_s,_id:tag._id.to_s,is_root:true).count > 0
    end
  end

  def union_roots(roots_to_add)
    roots_to_add.each{|tag| tag.is_root = true}
  end

  def subtract_roots(roots_to_delete)
    roots_to_delete.each{|tag| tag.is_root = false}
  end

  def folksonomies
    PTag.where(taxonomy_id:self._id.to_s,is_folk:true).all
  end

  def folksonomy; folksonomies end

  def folksonomy_count
    PTag.where(taxonomy_id:self._id.to_s,is_folk:true).count
  end

  def has_folksonomy?(tag=nil)
    folks = folksonomy_count
    if folks < 1
      false
    elsif tag.nil?
      folks > 0
    else
      PTag.where(taxonomy_id:self._id.to_s,_id:tag._id.to_s,is_folk:true).count > 0
    end
  end

  def union_folksonomies(folks_to_add)
    folks_to_add.each{|tag| tag.is_folksonomy = true}
  end

  def subtract_folksonomies(folks_to_delete)
    folks_to_delete.each{|tag| tag.is_folksonomy = false}
  end

end

class PTag
  include MongoMapper::Document
  key :name, String
  key :parent_ids, Array
  key :children_ids, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :item_ids, Array
#  key :taxonomy_id, ObjectId
  belongs_to :taxonomy, :class_name => 'PTaxonomy'
  many :items, :class_name => 'PItem', :in => :item_ids
  many :parents, :class_name => 'PTag', :in => :parent_ids
  many :children, :class_name => 'PTag', :in => :children_ids

  def register_root; set(is_root:true,is_folk:false) end

  def register_folksonomy; set(is_root:false,is_folk:true) end

  def register_offspring; set(is_root:false,is_folk:false) end

  def get_parents_names
    parents.map{|parent| parent.name}
  end

  def get_children_names
    children.map{|child| child.name}
  end

end

class PAlbum
  include MongoMapper::Document
  key :name, String
  key :date, String
  key :content, String
#  key :taxonomy_id, ObjectId
  belongs_to :taxonomy, :class_name => 'PTaxonomy'
  many :items, :class_name => 'PItem'

end

class PItem
  include MongoMapper::Document
  key :name, String
  key :date, String
  key :content, String
  key :sees, Array
  key :tag_ids, Array
#  key :album_id, ObjectId
  many :tags, :class_name => 'PTag', :in => :tag_ids
  belongs_to :album, :class_name => 'PAlbum'

end

#tax = Taxonomy.new(name:'MyTax')
#tax.add_album('MyAlbum')
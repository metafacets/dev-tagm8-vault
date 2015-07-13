require 'active_support'
require 'mongo_mapper'

module Tagm8Db
  def open(db)
    @db = db
    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = db
    PTaxonomy.ensure_index :name, :unique => true
    PTag.ensure_index :_id
    PTag.ensure_index :name
    PTag.ensure_index :is_root
    PTag.ensure_index :is_folk
    PTag.ensure_index :taxonomy
    PTag.ensure_index :items
    PItem.ensure_index :name
    PItem.ensure_index :tags
    PItem.ensure_index :album
  end
  def wipe
    MongoMapper.connection.drop_database(@db)
  end
  module_function :open, :wipe
end

class PTaxonomy
  # PTaxonomy <->> PTag    - manual
  # PTaxonomy <->> PAlbum  - ODM
  include MongoMapper::Document
  key :name, String
  key :dag, String
  many :albums, :class_name => 'PAlbum'

  def self.count_by_name(name=nil)
    name.nil? ? PTaxonomy.count : PTaxonomy.where(name:name.to_s).size
  end

  def self.get_by_name(name)
    PTaxonomy.first(name:name)
  end

  def self.list(name=nil)
    res = PTaxonomy.all.map {|tax| tax.name}
    res = res.select {|tax_name| tax_name == name} unless name.nil?
    res
  end

  def list_tags_by_id(ids)
    ids.map{|id| PTag.first(_id:id.to_s)}.select{|tag| tag.name unless tag.nil?}
  end

#  def get_tag(id)
#    PTag.first(_id:id.to_s)
#  end

#  def get_tags(ids)
#    ids.map{|id| PTag.first(_id:id.to_s)}
#  end

  def get_tag_by_name(name)
    PTag.first(taxonomy:self._id.to_s,name:name)
  end

  def get_tag_by_id(id)
    PTag.first(taxonomy:self._id.to_s,_id:id)
  end

  def tags
    PTag.where(taxonomy:self._id.to_s).all
  end

  def list_tags
    tags.map{|tag| tag.name}
  end

  def count_tags(name=nil)
    if name.nil?
      PTag.where(taxonomy:self._id.to_s).size
    else
      PTag.where(taxonomy:self._id.to_s,name:name.to_s).size
    end
  end

  def subtract_tags(tags_to_delete)
    tags_to_delete.each {|tag| tag.delete}
  end

  def roots
    PTag.where(taxonomy:self._id.to_s,is_root:true).all
  end

  def count_roots
    PTag.where(taxonomy:self._id.to_s,is_root:true).size
  end

  def has_root?(tag=nil)
    roots = count_roots
    if roots < 1
      false
    elsif tag.nil?
      roots > 0
    else
      PTag.where(taxonomy:self._id.to_s,_id:tag._id.to_s,is_root:true).count > 0
    end
  end

  def union_roots(roots_to_add)
    roots_to_add.each{|tag| tag.is_root = true}
  end

  def subtract_roots(roots_to_delete)
    roots_to_delete.each{|tag| tag.is_root = false}
  end

  def folksonomies
    PTag.where(taxonomy:self._id.to_s,is_folk:true).all
  end

  def folksonomy; folksonomies end

  def count_folksonomies
    PTag.where(taxonomy:self._id.to_s,is_folk:true).size
  end

  def has_folksonomy?(tag=nil)
    folks = count_folksonomies
    if folks < 1
      false
    elsif tag.nil?
      folks > 0
    else
      PTag.where(taxonomy:self._id.to_s,_id:tag._id.to_s,is_folk:true).count > 0
    end
  end

  def union_folksonomies(folks_to_add)
    folks_to_add.each{|tag| tag.is_folk = true}
  end

  def subtract_folksonomies(folks_to_delete)
    folks_to_delete.each{|tag| tag.is_folk = false}
  end

  def count_albums(name=nil)
    if name.nil?
      albums.count
    else
      albums.select {|alm| alm.name == name}.size
    end
  end

  def list_albums(name=nil)
    res = albums.map {|album| album.name}
    res = res.select {|album_name| album_name == name} unless name.nil?
    res
  end

  def get_album_by_name(name)
    albums.select {|alm| alm.name == name}.first
  end

end

class PTag
  # PTaxonomy <->> PTag - manual (because ODM can't handle recursive parents and children links)
  # PTag <<->> PItem    - ODM
  include MongoMapper::Document
  key :name, String
  key :parents, Array
  key :children, Array
  key :items, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :item_dependent, Boolean # delete this tag if true and no items, false if ever instantiated outwith an item (e.g. via Facade.add_tags)
  key :taxonomy, String
  key :item_ids, Array
  many :items, :class_name => 'PItem', :in => :item_ids

  def self.count_by_name(name=nil)
    name.nil? ? PTag.count : PTag.where(name:name.to_s).size
  end

  def self.get_by_name(name=nil)
    name.nil? ? PTag.all : PTag.where(name:name.to_s).all
  end

  def self.get_by_id(id)
    PTag.first(_id:id.to_s)
  end

  def self.list(name=nil)
    res = PTag.all.map {|tax| tax.name}
    res = res.select {|tag_name| tag_name == name} unless name.nil?
    res
  end

  def get_taxonomy
    PTaxonomy.first(_id:taxonomy)
  end

  def get_parents
    parents.map{|id| PTag.first(_id:id.to_s)}.select{|tag| tag unless tag.nil?}
  end

  def has_parent?(tag=nil)
    tags = PTag.first(_id:_id.to_s).parents
    if tag.nil?
      !tags.empty?
    else
      tags.include?(tag._id.to_s)
    end
  end

  def union_parents(parents)
    parents.each{|parent| add_to_set(parents:parent._id.to_s)}
  end

  def subtract_parents(parents)
    pull_all(parents:parents.map{|parent| parent._id.to_s})
  end

  def get_children
    children.map{|id| PTag.first(_id:id.to_s)}.select{|tag| tag unless tag.nil?}
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

  def union_children(children)
    children.each{|child| add_to_set(children:child._id.to_s)}
  end

  def subtract_children(children)
    pull_all(children:children.map{|child| child._id.to_s})
  end

  def list_items
    items.map{|item| item.name}
  end

  def union_items(items)
    items.each{|item| add_to_set(items:item._id.to_s)} # manual mapping only
    self.items |= items
    save
  end

  def register_root; set(is_root:true,is_folk:false) end

  def register_folksonomy; set(is_root:false,is_folk:true) end

  def register_offspring; set(is_root:false,is_folk:false) end

end

class PAlbum
  # PTaxonomy <->> PAlbum - ODM
  # PItem <<-> PAlbum     - ODM
  include MongoMapper::Document
  key :name, String
  key :date, String
  key :content, String
  belongs_to :taxonomy, :class_name => 'PTaxonomy'
  many :items, :class_name => 'PItem'

  def self.count_by_name(name=nil)
    name.nil? ? PAlbum.count : PAlbum.where(name:name.to_s).size
  end

  # to be used by Facade.list|rename|delete_albums
  def self.get_by_name(name=nil)
    name.nil? ? PAlbum.all : PAlbum.where(name:name.to_s).all
  end

  def self.list(name=nil)
    res = PAlbum.all.map {|alm| alm.name}
    res = res.select {|album_name| album_name == name} unless name.nil?
    res
  end

  def get_item_by_name(name)
    items.select {|item| item.name == name}.first
  end

  def count_items(name=nil)
    if name.nil?
      items.count
    else
      items.select {|item| item.name == name}.size
    end
  end

  def list_items(name=nil)
    # optional name parameter for Facade.list_items
    res = items.map {|item| item.name}
    res = res.select {|item_name| item_name == name} unless name.nil?
    res
  end

end

class PItem
  # PItem <<-> PAlbum - ODM
  # PTag <<->> PItem  - ODM
  include MongoMapper::Document
  key :name, String
  key :original_name, String
  key :date, String
  key :original_content, String
  key :logical_content, String
  key :original_tag_ids, String
  key :sees, Array
  key :tag_ids, Array
  many :tags, :class_name => 'PTag', :in => :tag_ids
  belongs_to :album, :class_name => 'PAlbum'

  def self.count_by_name(name=nil)
    name.nil? ? PItem.count : PItem.where(name:name.to_s).size
  end

  # to be used by Facade.list|rename|delete_items
  def self.get_by_name(name)
    PItem.where(name:name.to_s).all
  end

#  # only needed if Item.open(name) is supported
#  def self.get_by_name(name)
#    PItem.first(name:name)
#  end

  def self.list
    PItem.all.map {|tax| tax.name}
  end

  def get_tag_by_id(id)
    tags.select{|tag| tag._id == id}.first
#    PItem.all(:_id => self._id, :tag_ids => id).first
  end

  def union_tags(tags)
    self.tags |= tags.map{|tag| tag._id.to_s}
  end

end


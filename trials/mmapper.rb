require 'active_support'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'tagm8-trial'
MongoMapper.connection.drop_database('tagm8-trial')

class PTaxonomy
  include MongoMapper::Document
  key :name, String
  many :tags, :class_name => 'PTag'
  #attr_accessible :name, :tags

  def get_tag_by_name(name)
    PTag.first(taxonomy:taxonomy.to_s,name:name.to_s)
  end

  def get_tag(id)
    PTag.first(taxonomy:taxonomy.to_s,_id:id.to_s)
  end

  def tag_count
    PTag.where(taxonomy:self._id.to_s).count
  end

  def has_tag?(name=nil)
    tags = tag_count
    if tags < 1
      result = false
    elsif name.nil?
      result = tags > 0
    else
      result = PTag.where(taxonomy:self._id.to_s,name:name.to_s).count > 0
    end
    puts "PTaxonomy.has_tag: self._id=#{self._id}, tags=#{tags}, name=#{name}, result=#{result}"
    result
  end

  def add_tag(child_name,parent_name=nil)
    child = get_lazy_tag(child_name)
    unless parent_name.nil?
      parent = get_lazy_tag(parent_name)
      puts "PTaxonomy.add_tag: child=#{child}, parent=#{parent}"
      add_link(child,parent)
    end
  end

  def add_link(child,parent)
    puts "PTaxonomy.add_link: child=#{child}, parent=#{parent}, child._id=#{child._id}"
    child.add_to_set(parents:parent._id.to_s)
    parent.add_to_set(children:child._id.to_s)
    child.set(is_folk:false,is_root:false)
    parent.set(is_folk:false,is_root:true)
  end

  def root_count
    PTag.where(taxonomy:_id.to_s,is_root:true).count
  end

  def has_root?(tag=nil)
    roots = root_count
    if roots < 1
      false
    elsif tag.nil?
      roots > 0
    else
      PTag.where(taxonomy:_id.to_s,_id:tag._id.to_s,is_root:true).count > 0
    end
  end

  def folksonomy_count
    PTag.where(taxonomy:_id.to_s,is_folk:true).count
  end

  def has_folksonomy?(tag=nil)
    folks = folksonomy_count
    if folks < 1
      false
    elsif tag.nil?
      folks > 0
    else
      PTag.where(taxonomy:_id.to_s,_id:tag._id.to_s,is_folk:true).count > 0
    end
  end
end

class PTag
  include MongoMapper::Document
  key :name, String
  key :parents, Array
  key :children, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :taxonomy, String
  #attr_accessible :name, :parents, :children, :is_root, :is_folk, :taxonomy

  def has_parent?(tag=nil)
    if tag.nil?
      !parents.to_a.empty?
    else
      parents.include?("#{tag._id}")
    end
  end

end

class Taxonomy < PTaxonomy

  def initialize(name)
    super(name:name)
    save
  end

  def get_lazy_tag(name)
    if has_tag?(name)
      tag = get_tag(name)
    else
      tag = Tag.new(name,self)
    end
    puts "PTaxonomy.get_lazy_tag: tag=#{tag}"
    tag
  end
end

class Tag < PTag
  def initialize(name,taxonomy)
    super(name:name,taxonomy:taxonomy._id)
    @is_folk = true
    @is_root = false
    save
  end

end

tax = Taxonomy.new(name:'tax1')
#tax.save
tax.add_tag(:java,:language)
tax.add_tag(:python,:language)
tax.add_tag(:john)
john = tax.get_lazy_tag(:john)
java = tax.get_lazy_tag(:java)
python = tax.get_lazy_tag(:python)
#java.save
puts "tax=#{tax}, java=#{java}"
lang = tax.get_lazy_tag(:language)
puts "root coount=#{Tag.where(taxonomy:"#{tax._id}", is_root:true).count}"
puts "has_root?(lang)=#{tax.has_root?(lang)}"
puts "has_folk?(john)=#{tax.has_folksonomy?(john)}"
puts "python.has_parent?(lang)=#{python.has_parent?(lang)}"
roots = Tag.where(taxonomy:tax._id.to_s,is_root:true).all.map{|r| tax.get_tag(r.name.to_s)}
puts "roots=#{roots}"
#lang.pull_all(:children => ["#{java._id}","#{python._id}"])
#java.delete

#java = Tag.new(name:'java')
#python = Tag.new(name:'python')
#prog = Tag.new(name:'programming languages',children:[java],is_root:true)
#tax1 = Taxonomy.new(name:'tax1',tags:[java,python])
#tax1.save
#puts tax1.has_tag?
#prog.update_attribute(:children,[java._id,python._id])
##tax1.tags << [java,prog]
#puts "tax1=#{tax1}"
#tax1.tags.each{|t| puts t.name}
#puts "Tags:"
#Tag.all.each {|n| puts n._id}
#tag = Tag.find('54671c3a25149725ac000003')
#puts tag
#   puts "Tag.all({criteria})=#{Tag.all(name:'java',is_folk:false)}"
#puts "Tag.first=#{Tag.first}"
#   Tag.where(:name.gt => 'java').each {|i| puts i.name}
#puts "roots coount = #{Tag.all(is_root:true).size}"
#puts "java is_root = #{java.is_root}"
#puts "prog.children.include?(java) = #{prog.children.include?(java._id)}"
#puts "tax1 has_tags=#{!tax1.tags.empty?}"
#puts "tax1 has_root(java)=#{!tax1.tags.all(name:'java',is_root:true).empty?}"


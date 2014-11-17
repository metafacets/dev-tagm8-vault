require 'active_support'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'mmapper'
MongoMapper.connection.drop_database('mmapper')

class PTaxonomy
  include MongoMapper::Document
  key :name, String
  many :tags, :class_name => 'PTag'
end

class PTag
  include MongoMapper::Document
  key :name, String
  key :parents, Array
  key :children, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :taxonomy, String
end

class Taxonomy < PTaxonomy
end

class Tag < PTag
  def initialize(hash=nil)
    super(hash)
    @is_folk = true
    @is_root = false
  end
end

java = Tag.new(name:'java',is_root:true)
python = Tag.new(name:'python')
prog = Tag.new(name:'programming languages',children:[java],is_root:true)
tax1 = Taxonomy.new(name:'tax1',tags:[java,python])
prog.update_attribute(:children,[java._id,python._id])
#tax1.tags << [java,prog]
puts "tax1=#{tax1}"
tax1.tags.each{|t| puts t.name}
puts "Tags:"
Tag.all.each {|n| puts n._id}
tag = Tag.find('54671c3a25149725ac000003')
puts tag
puts "Tag.all({criteria})=#{Tag.all(name:'java')}"
puts "Tag.first=#{Tag.first}"
Tag.where(:name.gt => 'java').each {|i| puts i.name}
puts "roots coount = #{Tag.all(is_root:true).size}"
puts "java is_root = #{java.is_root}"
puts "prog.children.include?(java) = #{prog.children.include?(java._id)}"


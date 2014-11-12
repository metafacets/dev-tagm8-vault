require 'active_support'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'mmapper'
MongoMapper.connection.drop_database('mmapper')

class Taxonomy
  include MongoMapper::Document
  key :name, String
  many :tags
end

class Tag
  include MongoMapper::Document
  key :name, String
  key :parents, Array
  key :children, Array
  key :is_root, Boolean
  key :is_folk, Boolean
end


java = Tag.new(name:'java')
python = Tag.new(name:'python')
prog = Tag.new(name:'programming languages',children:[java])
tax1 = Taxonomy.new(name:'tax1',tags:[java,python])
prog.update_attribute(:children,[java._id,python._id])
tax1.tags << [java,prog]

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
  key :items, Array
  key :is_root, Boolean
  key :is_folk, Boolean
  key :taxonomy, String
end

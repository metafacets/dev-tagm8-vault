require 'mongoid'
#require 'rails/mongoid'

ENV["RACK_ENV"] ||= 'development'
#Mongoid.load!('..\src\config\mongoid.yml','development')
Mongoid.load!('..\src\config\mongoid.yml')
Mongoid.truncate!

class Taxonomy
  include Mongoid::Document
  field :name, type:String
  has_many :tags
end

class Tag
  include Mongoid::Document
  field :name, type:String
  field :children, type:Array
  field :parents, type:Array
  field :root?, type:Boolean
  field :folk?, type:Boolean
  belongs_to :taxonomy

  index({name:1},{unique:true})
end

java = Tag.create(name:'Java')
puts java
java = Tag.new(name:'Java')
puts java, java.name
java.
#mytags = []
#['java','python','ruby'].each_with_index {|v,i| mytags[i] = Tag.create(name:v)}
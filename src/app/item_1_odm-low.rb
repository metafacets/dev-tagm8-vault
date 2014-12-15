require_relative 'debug'
require_relative '../../src/app/tag_1_odm-low'
require_relative '../../src/model/mongo_mapper-db_1_odm-low'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Album < PAlbum
#  attr_accessor :name, :items

  def initialize(name,taxonomy)
    super(name:name,taxonomy:taxonomy._id)
    save
  end

  def add_item(entry=nil)
    unless !entry.is_a? String || entry.nil? || entry.empty?
      Item.new(entry,self)
    else
      nil
    end
  end

end

class Item < PItem

#  def self.taxonomy=(taxonomy) @@taxonomy = taxonomy end
#  def self.taxonomy; @@taxonomy; end

#  attr_accessor :date, :name, :content, :tags, :sees, :album

  def initialize(entry,album)
    super(date:Time.now,tags:[],album:album._id)
    parse(entry)
    save
#    puts "Item.initialize: name=#{name}, date=#{date}, album=#{album}, tags=#{tags}"
  end

  def get_taxonomy
    get_album.get_taxonomy
  end

  def parse(entry)
    parse_entry(entry)
    parse_content
  end

  def parse_entry(entry)
    # gets @name and @content
    first, *rest = entry.split("\n")
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['first',first],['rest',rest]])
    self.name = first if first
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['name',name],['rest',rest]])
    if rest
      self.content = rest.join("\n")
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['content',content]])
    end
  end

  def parse_content
    # gets content tags
    # + or - solely instantiate or deprecate the taxonomy
    # otherwise taxonomy gets instantiated and item gets tagged by its leaves
    unless content.empty?
      content.scan(/([+|\-|=]?)#([^\s]+)/).each do |op,tag_ddl|
        Debug.show(class:self.class,method:__method__,note:'1',vars:[['op',op],['tag_ddl',tag_ddl]])
        if op == '-'
          subtract_tags(get_taxonomy.deprecate(tag_ddl))
#          @tags -= Item.taxonomy.deprecate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2a',vars:[['tags',tags],['Item.taxonomy.tags',Item.taxonomy.tags]])
        else
          leaves = get_taxonomy.instantiate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2',vars:[['leaves',leaves]])
          if op == '' || op == "="
            leaves.each {|tag| tag.union_items([self])}
            union_tags(leaves)
#            @tags |= leaves
            Debug.show(class:self.class,method:__method__,note:'2b',vars:[['tags',tags],['get_taxonomy.tags',get_taxonomy.tags]])
          end
        end
      end
    end
  end

  def query_tags
    # get tags matching this item - the long way from the Taxonomy
    # used for testing
    result = []
#    get_taxonomy.get_tags.each_value {|tag| result |= [tag] if tag.items.include? self}
    get_taxonomy.tags.each_value {|tag| result |= [tag] if tag.items.include? self}
    result
  end

end

MongoMapper.connection.drop_database('tagm8')
tax = Taxonomy.new('MyTax')
clx = Album.new('MyAlbum',tax)
puts "clx=#{clx}, clx.name=#{clx.name}, clx.id=#{clx.id}, clx.taxonomy=#{clx.taxonomy}, clx.get_taxonomy=#{clx.get_taxonomy}"
tax.instantiate('[:cat,:dog]<:mammal')
puts "tax.tags=#{tax.tags}"
item = clx.add_item("Item 1\n+#[mammal,fish]<:animal>[insect,bird>[parrot,eagle]]\nMy entry =#cat,fish #:dog for my cat and dog")
##item = Item.new("Item 1\n+#[mammal,fish]<:animal>[insect,bird>[parrot,eagle]]\nMy entry =#cat,fish #:dog for my cat and dog",clx)
puts "item=#{item}, date=#{item.date}, name=#{item.name}, content=#{item.content}, get_tags=#{item.tags}"
#puts "tax.tags=#{tax.tags}"

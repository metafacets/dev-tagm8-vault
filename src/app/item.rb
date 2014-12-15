require_relative 'debug'
require_relative 'tag'
require_relative '../../src/model/mongo_mapper-db'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Album < PAlbum

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

  def initialize(entry,album)
    super(date:Time.now,album:album)
    instantiate(entry)
  end

  def instantiate(entry)
    parse(entry)
    save
#    puts "Item.instantiate: name=#{name}, date=#{date}, album=#{album}, tags=#{tags}"
    self
  end

  def get_taxonomy
    album.taxonomy
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
          self.tags -= get_taxonomy.deprecate(tag_ddl)
#          @tags -= Item.taxonomy.deprecate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2a',vars:[['tags',tags],['Item.taxonomy.tags',Item.taxonomy.tags]])
        else
          leaves = get_taxonomy.instantiate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2',vars:[['leaves',leaves]])
          if op == '' || op == "="
            leaves.each {|tag| tag.union_items([self])}
            self.tags << leaves
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
    get_taxonomy.tags.each_value {|tag| result |= [tag] if tag.items.include? self}
    result
  end

end

## RECENT TESTS ##

#MongoMapper.connection.drop_database('tagm8')
#tax = Taxonomy.new(name:'MyTax')
#clx = tax.add_album('MyAlbum')
#item1 = clx.add_item("Item 1\ncontent 1")
#item2 = clx.add_item("Item 2\ncontent 2")
#puts "clx=#{clx}, clx.name=#{clx.name}, clx.id=#{clx.id}, clx.taxonomy=#{clx.taxonomy}, clx.items=#{clx.items}"
##item3 = Item.new.instantiate("Item 3\ncontent 3")
##clx.add_to_set(items:item3)
##puts "clx=#{clx}, clx.name=#{clx.name}, clx.id=#{clx.id}, clx.taxonomy=#{clx.taxonomy}, clx.items=#{clx.items}"
#puts "item1=#{item1}, date=#{item1.date}, name=#{item1.name}, content=#{item1.content}, album=#{item1.album}, album.name=#{item1.album.name}, taxonomy=#{item1.album.taxonomy}"

## ORIGINAL TESTS ##

#tax.instantiate('[:cat,:dog]<:mammal')
#puts "tax.tags=#{tax.tags}"
#item4 = clx.add_item("Item 4\n+#[mammal,fish]<:animal>[insect,bird>[parrot,eagle]]\nMy entry =#cat,fish #:dog for my cat and dog")
#puts "item=#{item4}, date=#{item4.date}, name=#{item4.name}, content=#{item4.content}, get_tags=#{item4.tags}"
#puts "tax.tags=#{tax.tags}"








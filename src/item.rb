require_relative 'debug.rb'
require_relative 'tag.rb'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Item

  def self.taxonomy=(taxonomy) @@taxonomy = taxonomy end
  def self.taxonomy; @@taxonomy; end
  def self.items=(items) @@items = items end
  def self.items; @@items end

  attr_accessor :date, :name, :content, :tags, :sees

  Item.items = []

  def initialize(entry=nil)
    @date = Time.now
    @name = ''
    @content = ''
    @tags = []
    @sees = []
    instantiate(entry)
  end

  def instantiate(entry)
    unless !entry.is_a? String || entry.nil? || entry.empty?
      parse(entry)
      Item.items |= [self]
    end
  end

  def parse(entry)
    parse_entry(entry)
    parse_content
  end

  def parse_entry(entry)
    # gets @name and @content
    first, *rest = entry.split("\n")
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['first',first],['rest',rest]])
    @name = first if first
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['name',name],['rest',rest]])
    if rest
      @content = rest.join("\n")
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['content',content]])
    end
  end

  def parse_content
    # gets content tags
    # + or - solely instantiate or deprecate the taxonomy
    # otherwise taxonomy gets instantiated and item gets tagged by its leaves
    unless content.empty?
      content.scan(/([+|-|=]?)#([^\s]+)/).each do |op,tag_ddl|
        Debug.show(class:self.class,method:__method__,note:'1',vars:[['op',op],['tag_ddl',tag_ddl]])
        if op == '-'
          @tags -= Item.taxonomy.deprecate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2a',vars:[['tags',tags],['Item.taxonomy.tags',Item.taxonomy.tags]])
        else
          leaves = Item.taxonomy.instantiate(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'2',vars:[['leaves',leaves]])
          if op == '' || op == "="
            leaves.each {|tag| tag.items |= [self]}
            @tags |= leaves
            Debug.show(class:self.class,method:__method__,note:'2b',vars:[['tags',tags],['Item.taxonomy.tags',Item.taxonomy.tags]])
          end
        end
      end
    end
  end

  def query_tags
    # get tags matching this item - the long way from the Taxonomy
    # used for testing
    result = []
    Item.taxonomy.tags.each_value {|tag| result |= [tag] if tag.items.include? self}
    result
  end
end


#tax = Taxonomy.new
#tax.instantiate('[:cat,:dog]<:mammal')
#puts tax.tags
#Item.taxonomy = tax
#item = Item.new("Item 1\n+#[mammal,fish]<:animal>[insect,bird>[parrot,eagle]]\nMy entry =#cat,fish #:dog for my cat and dog")
#puts "item=#{item}, date=#{item.date}, name=#{item.name}, content=#{item.content}, tags=#{item.tags}"
#puts "tax.tags=#{tax.tags}"






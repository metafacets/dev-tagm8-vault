require_relative 'debug'
require_relative 'tag'
require_relative '../../src/model/mongo_mapper-db'

#Debug.new(class:'Tag') # comment out to turn off
#Debug.new(method:'abstract')

class Album < PAlbum

  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  # create new or open existing album by name
  # postpone - needs to pass a loaded taxonomy for new album
  #def self.lazy(name)
  #  alm = self.open(name)
  #  alm = self.new(name) if alm.nil?
  #  alm
  #end

  def initialize(name,taxonomy)
    super(name:name,taxonomy:taxonomy)
    save
  end

  def rename(name)
    self.name = name
    save
  end

  def add_item(entry=nil)
    unless !entry.is_a? String || entry.nil? || entry.empty?
      Item.new(self).instantiate(entry)
    else
      nil
    end
  end

  def delete_items(item_list)
    # deletes items, and subtracts them from associated tags
    # deletes associated tags if these exist solely because of the deleted items
    found = list_items&item_list
    tags_to_delete = []
    found.each do |item_name|
      item = get_item_by_name(item_name)
      item.tags.each do |tag|
        tag.items -= [item]
        tags_to_delete |= [tag.name] if tag.item_dependent && tag.items.empty?
      end
      self.items -= [item]
      item.delete
    end
    tags_to_delete.each{|name| taxonomy.delete_tag(name)}
    save
  end

  def has_item?(name=nil) count_items(name) > 0 end

  def query_items(query)
    taxonomy.query_items(query)&items
  end

end

class Item < PItem

  def self.exists?(name=nil)
    name.nil? ? self.count > 0 : self.count_by_name(name) > 0
  end

  def initialize(album)
    super(date:Time.now,album:album)
    album.save
    save
  end

  def rename(name)
    self.name = name
    save
  end

  def instantiate(entry)
    parse(entry)
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
    # extracts @name and @original_content
    first, *rest = entry.strip.split("\n") # preserve item content internal whitespace
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['first',first],['rest',rest]])
    if first
      self.name = first.strip              # strip name trailing whitespace
      self.original_name = first if self.original_name.nil?
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['name',name],['rest',rest]])
    end
    if rest
      self.original_content = rest.join("\n")
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['original_content',original_content]])
    end
    save
  end

  def parse_content
    # extracts @tags and @original_tag_ids
    # + or - solely instantiate or deprecate the taxonomy
    # otherwise taxonomy gets instantiated and item gets tagged by all supplied tags (not just supplied leaves) incase any later get deleted
    unless original_content.empty?
      supplied_ddl = []
      supplied_tags = []
      original_content.scan(/([+|\-|=]?)#([^\s]+)/).each do |op,tag_ddl|
        unless supplied_ddl.include?(tag_ddl)
          Debug.show(class:self.class,method:__method__,note:'1',vars:[['op',op],['tag_ddl',tag_ddl]])
          if op == '-'
            _,supplied = get_taxonomy.exstantiate(tag_ddl)  # was leaves,supplied = ...
            self.tags -= supplied                           # leaves | supplied ?
            Debug.show(class:self.class,method:__method__,note:'2a',vars:[['tags',tags],['get_taxonomy.tags',get_taxonomy.tags]])
          else
            _,supplied = get_taxonomy.instantiate(tag_ddl)  # was leaves,supplied = ...
            if op == '' || op == '='
              supplied.each {|tag| tag.union_items([self])} # leaves | supplied ?
              self.tags |= supplied                         # leaves | supplied ?
              Debug.show(class:self.class,method:__method__,note:'2b',vars:[['tags',tags],['get_taxonomy.tags',get_taxonomy.tags]])
            end
          end
          supplied_ddl << tag_ddl
          supplied_tags |= supplied
        end
      end
      set_logical_content(supplied_tags)
      save
    end
  end

  def set_logical_content(supplied_tags)
    # sets original_tag_ids and logical_content (where tags are represented by their ids for easy name substitution)
    result = original_content.dup
    unless supplied_tags.empty?
      name_id = supplied_tags.map{|tag| [tag.name,tag._id.to_s] unless tag.nil?}.select{|tag| tag unless tag.nil?}.sort_by{|e| e[0].length}.reverse
      unless name_id.empty?
        self.original_tag_ids = name_id.join(',')
        tail = original_content.dup
        while tail =~ /#([^\s]+)((.|\n)*)/
          ddl,tail = $1,$2
          ddl_sub = ddl.dup
          name_id.each{|name,id| ddl_sub.gsub!(name,id.upcase)}
          result.gsub!("##{ddl}#{tail}","##{ddl_sub.downcase}#{tail}")
        end
      end
    end
    self.logical_content = result
  end

  def get_content
    # re-generates item content using latest tag names
    # substituting logical_content tag ids for names if they exist or else with original names marked as deleted
    result = logical_content.dup
    unless self.original_tag_ids.nil?
      # transform substitutions into array of paired old lowercase and new uppercase tag names including unchanged
      name_id = original_tag_ids.split(',').each_slice(2).to_a
      name_id.each do |orig_name,id|
        Tag.get_by_id(id).nil? ? name = "#{orig_name}_deleted" : name = Tag.get_by_id(id).name
        result.gsub!(id,name)
      end
    end
    result
  end

  def inspect; "#{self.name}\n#{get_content}" end

  def to_s; inspect end

  def query_tags
    # get tags matching this item - the long way from the Taxonomy
    # used for testing
    result = []
    get_taxonomy.tags.each {|tag| result |= [tag] if tag.items.include? self}
    result
  end

end

## RECENT TESTS ##

#MongoMapper.connection.drop_database('tagm8')
#tax = Taxonomy.new(name:'MyTax')
#puts "tax=#{tax}, tax.name=#{tax.name}, tax.id=#{tax.id}"
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








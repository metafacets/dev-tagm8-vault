require_relative 'debug.rb'
require_relative 'tag.rb'

class Query
  def self.raw_ql=(raw_ql)
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['raw_ql',raw_ql],['raw_ql.class',raw_ql.class]])
    raw_ql.is_a?(String) ? raw_ql = raw_ql : raw_ql = nil
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['raw_ql',raw_ql],['raw_ql.class',raw_ql.class]])
    @@raw_ql = raw_ql
  end
  def self.raw_ql; @@raw_ql end
  def self.ql=(query) @@ql = query end
  def self.ql; @@ql end
  def self.taxonomy=(taxonomy)
    taxonomy.is_a?(Taxonomy) ? tx = taxonomy : tx = nil
    @@taxonomy = tx
  end
  def self.taxonomy; @@taxonomy end

  def self.parse(raw_ql)
    self.raw_ql = raw_ql
    unless self.taxonomy.nil? || self.raw_ql.nil?
      self.interpolate
#    self.fix_errors
    end
  end

  def self.interpolate
    query = self.raw_ql.dup
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['query',query],['query.class',query.class]])
    ':_,'.each_char {|op| query = eval("query.gsub(/#{op}+/,op)")}  # filter obvious duplicates
    query = query.gsub(/#([a-zA-Z1-9]+)/,'get_tag(\'\1\'.to_sym).query_items')
#    puts "Query.pre_process 1: self.raw_ql=#{self.raw_ql}, query=#{query}"
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['query',query],['query.class',query.class]])
    self.ql = query
    query
  end

end

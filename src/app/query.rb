require_relative 'debug'
#require_relative 'tag'

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
    [':','\s'].each {|char| query = eval("query.gsub(/#{char}/,'')")} # filter redundant
    query.gsub!(/([a-zA-Z1-9_]+)(#[a-zA-Z1-9_]+)/,'\1&\2')            # missing operator, interpret as &
    query.gsub!(/,/,'|')                                              # , = |
    query.gsub!(/\+/,'&')                                             # + = &
    query.gsub!(/\|+/,'|')                                            # filter repeated |
    query.gsub!(/&+/,'&')                                             # filter repeated &
    temp = query.dup
    temp.scan(/#?:?[a-zA-Z1-9_]+/).each do |match|                    # interpolate tag syntax including misnamed or missing tags
      name = match.downcase
      name.gsub!(/^#?/,'')
      name.gsub!(/.*_$/,'[]')
      name.gsub!(/^\d.*/,'[]')
      name != '[]' && self.taxonomy.has_tag?(name.to_sym) ? name = "get_tag_by_name('#{name}'.to_sym).query_items" : name = '[]'
#      puts "Query.pre_process 1: match=#{match}, name=#{name}"
      query.gsub!(/#{match}/,name)
    end
#    puts "Query.pre_process 2: self.raw_ql=#{self.raw_ql}, query=#{query}"
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['query',query],['query.class',query.class]])
    self.ql = query
    query
  end

end

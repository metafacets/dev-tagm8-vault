require_relative 'debug'

class Ddl
  def self.raw_ddl=(raw_ddl)
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['raw_ddl',raw_ddl],['raw_ddl.class',raw_ddl.class]])
    raw_ddl = '' unless raw_ddl.is_a? String
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['raw_ddl',raw_ddl],['raw_ddl.class',raw_ddl.class]])
    @@raw_ddl = raw_ddl
  end
  def self.raw_ddl; @@raw_ddl end
  def self.pre_ddl=(pre_ddl) @@pre_ddl = pre_ddl end
  def self.pre_ddl; @@pre_ddl end
  def self.ddl=(ddl) @@ddl = ddl end
  def self.ddl; @@ddl end
  def self.tags=(tags) @@tags = tags end
  def self.tags; @@tags end
  def self.has_tags?; !self.tags.empty? end
  def self.links=(links) @@links = links end
  def self.links; @@links end
  def self.leaves=(leaves) @@leaves = leaves end
  def self.leaves; @@leaves end
  def self.parse(raw_ddl)
    self.raw_ddl = raw_ddl
    self.prepare
    self.process
  end
  def self.prepare
    self.pre_process
    self.fix_errors
  end
  def self.process
    begin
      # copy Taxonomy
      self.wipe
      self.get_structure(self.ddl)
      self.get_leaves
    rescue
      # restore Taxonomy copy
    end
  end
  def self.wipe
    self.tags = []
    self.links = []
    self.leaves = []
  end
  def self.get_structure(ddl)
    # gets tags and links from tag_ddl
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['ddl',ddl],['self.tags',self.tags]])
    or_tags = lambda {|stack|
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['stack',stack]])
      stack.each {|i| self.tags |= i}
    }
    stack = []
    link = false
    ddl.reverse.each_with_index do |tag, idx|
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['tag',tag],['idx',idx],['tag.class',tag.class],['stack',stack]])
      if tag.is_a? Array
        stack << self.get_structure(tag)
      elsif tag == '>' || tag == '<'
        link = tag
      elsif tag.is_a? String
        stack << [tag.to_sym]
      elsif tag.is_a? Symbol
        stack << [tag]
      end
      Debug.show(class:self.class,method:__method__,note:'3',vars:[['tag',tag],['stack',stack]])
      if link && tag != '>' && tag != '<' && stack.size > 1
        or_tags.call(stack) unless stack.empty?
        first = stack.pop
        second = stack.pop
        Debug.show(class:self.class,method:__method__,note:'Add Links 1',vars:[['link',link],['first',first],['second',second],['idx',idx]])
        link == '>' ? self.links << [second,first] : self.links << [first,second]
        link = false
        i = ddl.size-idx-2                                            # next tag index in tag_ddl
        i > 0 && (ddl[i] == '>'||ddl[i] == '<') ? another_link = true : another_link = false
        another_link ? stack << first : stack << links[-1][1]             # if another link stack first, else stack this parent and add child to leaves
        Debug.show(class:self.class,method:__method__,note:'Add Links 2',vars:[['i',i],['ddl[i]',ddl[i]],['stack',stack],['self.links',self.links]])
      end
    end
    or_tags.call(stack)
    results = []
    stack.each {|i| results |= i}
    Debug.show(class:self.class,method:__method__,note:'4',vars:[['results',results]])
    results
  end
  def self.get_leaves
    # gets leaves from links
    if links.empty?
      leaves = self.tags
    else
      leaves = []
      parents = []
      links.each do |pair|
        leaves |= pair[0]
        parents |= pair[1]
      end
      Debug.show(class:self.class,method:__method__,note:'1',vars:[['leaves',leaves],['parents',parents]])
      leaves -= parents
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['leaves',leaves]])
    end
    self.leaves = leaves
  end
  def self.pre_process
    tag_ddl = self.raw_ddl.dup
    Debug.show(class:self.class,method:__method__,note:'1',vars:[['tag_ddl',tag_ddl],['tag_ddl.class',tag_ddl.class]])
    ':_,><'.each_char {|op| tag_ddl = eval("tag_ddl.gsub(/#{op}+/,op)")}  # filter obvious duplicates
    ['<>','><'].each {|op| tag_ddl = tag_ddl.gsub(op,op[0])}              # conflicting ops pick first
    '><'.each_char {|op| tag_ddl = tag_ddl.gsub(op,",'#{op}',")}          # separate ops into array els
    tag_ddl = tag_ddl.gsub('-','_')                                       # convert - to _
    tag_ddl = tag_ddl.gsub(/(\w)(:\w)/,'\1,\2')                           # missing commas
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['tag_ddl',tag_ddl],['tag_ddl.class',tag_ddl.class]])
    self.pre_ddl = tag_ddl
  end
  def self.fix_errors
    ok = false
    er = nil
    tag_ddl = self.pre_ddl.dup
    until ok do
      Debug.show(class:self.class,method:__method__,note:'2',vars:[['tag_ddl',tag_ddl]])
      begin
        self.ddl = eval(tag_ddl)
        self.ddl = [ddl] unless ddl.is_a? Array                           # guarantee array missed by SyntaxError
        ok = true
      rescue SyntaxError
        Debug.show(class:self.class,method:__method__,note:'SyntaxError')
        if er == 'SyntaxError'
          tag_ddl = '[]'
        else
          tag_ddl = "[#{tag_ddl}]"                                        # make array
          er = 'SyntaxError'
        end
      rescue NameError
        Debug.show(class:self.class,method:__method__,note:'NameError')
        if er == 'NameError'
          tag_ddl = '[]'
        else
          tag_ddl = tag_ddl.gsub(/(\w+)/i, ':\1')                         # form symbols
          tag_ddl = tag_ddl.gsub(/:+/,':')
          er = 'NameError'
        end
      end
    end
    Debug.show(class:self.class,method:__method__,note:'2',vars:[['self.ddl',self.ddl]])
  end
end
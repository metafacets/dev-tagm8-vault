class Ddl
  def self.raw_ddl=(raw_ddl)
    puts "raw_ddl 1: raw_ddl=#{raw_ddl}, raw_ddl.class=#{raw_ddl.class}"
    raw_ddl = '' unless raw_ddl.is_a? String
    puts "raw_ddl 2: raw_ddl=#{raw_ddl}, raw_ddl.class=#{raw_ddl.class}"
    @@raw_ddl = raw_ddl
  end
  def self.raw_ddl; @@raw_ddl end
  def self.pre_ddl=(pre_ddl) @@pre_ddl = pre_ddl end
  def self.pre_ddl; @@pre_ddl end
  def self.ddl=(ddl) @@ddl = ddl end
  def self.ddl; @@ddl end
  def self.tags=(tags) @@tags = tags end
  def self.tags; @@tags end
  def self.links=(links) @@links = links end
  def self.links; @@links end
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
      self.tags = []
      self.links = []
      self.abstract(self.ddl)
    rescue
      # restore Taxonomy copy
    end
  end
  def self.abstract(tag_ddl)
    puts "abstract 1: ddl=#{tag_ddl}, tags=#{self.tags}"
    or_tags = lambda {|stack|
      puts "do_status 1: stack=#{stack}"
      stack.each {|i| self.tags |= i}
    }
    stack = []
    link = false
    tag_ddl.reverse.each do |tag|
      puts "abstract 2: tag=#{tag}, tag.class=#{tag.class}, stack=#{stack}"
      if tag.is_a? Array
        stack << self.abstract(tag)
      elsif tag == '>' || tag == '<'
        link = tag
      elsif tag.is_a? String
        stack << [tag.to_sym]
      elsif tag.is_a? Symbol
        stack << [tag]
      end
      puts "abstract 3: tag=#{tag}, stack=#{stack}"
      if link && tag != '>' &&tag != '<' && stack.size > 1
        or_tags.call(stack) unless stack.empty?
        first = stack.pop
        second = stack.pop
        link == '>' ? self.links << [second,first] : self.links << [first,second]
        link = false
        stack << first
      end
    end
    or_tags.call(stack)
    results = []
    stack.each {|i| results |= i}
    puts "abstract 4: results=#{results}"
    results
  end
  def self.pre_process
    tag_ddl = self.raw_ddl.dup
    puts "instantiate 1: tag_ddl=#{tag_ddl}, tag_ddl.class=#{tag_ddl.class}"
    ':_,><'.each_char {|op| tag_ddl = eval("tag_ddl.gsub(/#{op}+/,op)")}  # filter obvious duplicates
    ['<>','><'].each {|op| tag_ddl = tag_ddl.gsub(op,op[0])}              # conflicting ops pick first
    '><'.each_char {|op| tag_ddl = tag_ddl.gsub(op,",'#{op}',")}          # separate ops into array els
    tag_ddl = tag_ddl.gsub('-','_')                                       # convert - to _
    tag_ddl = tag_ddl.gsub(/(\w)(:\w)/,'\1,\2')                           # missing commas
    self.pre_ddl = tag_ddl
  end
  def self.fix_errors
    ok = false
    er = nil
    tag_ddl = self.pre_ddl.dup
    until ok do
      puts "instantiate 2: tag_ddl=#{tag_ddl}"
      begin
        self.ddl = eval(tag_ddl)
        self.ddl = [ddl] unless ddl.is_a? Array                    # guarantee array missed by SyntaxError
        ok = true
      rescue SyntaxError
        puts "instantiate 2a: Syntax error"
        if er == 'SyntaxError'
          tag_ddl = '[]'
        else
          tag_ddl = "[#{tag_ddl}]"                                        # make array
          er = 'SyntaxError'
        end
      rescue NameError
        puts "instantiate 2a: Name error"
        if er == 'NameError'
          tag_ddl = '[]'
        else
          tag_ddl = tag_ddl.gsub(/(\w+)/i, ':\1')                         # form symbols
          tag_ddl = tag_ddl.gsub(/:+/,':')
          er = 'NameError'
        end
      end
    end
    puts "instantiate 3: ddl=#{self.ddl}"
  end
end
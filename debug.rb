class DebugItems < Hash
  def normalize!
    add_defaults!
    normalize_options!
    normalize_vars!
    normalize_level!
  end
  def add_defaults!
    {class:nil,method:nil,note:nil,vars:nil,level:0}.each {|k,v| self[k] = v unless self.has_key?(k)}
  end
  def normalize_options!
    [:class,:method,:note,:tags].each do |option|
      opt = self[option]
      self[option] = if opt.nil?
                       []
                     elsif opt.kind_of?(Array)
                       each.map {|o| o.to_s}
                     else
                       [opt.to_s]
                     end
    end
  end
  def normalize_vars!
    vars = []
    vars = if vars.kind_of?(Array)
             if self[:vars][0].kind_of?(Array)
               self[:vars]
             elsif self[:vars].size == 2
               [self[:vars]]
             end
           end
    self[:vars] = vars
  end
  def normalize_level!
    self[:level] = [self[:level]]
  end
end

class Debug
  @@outputs = []
  def self.show(debug_items={})
    puts "Debug.self.show 1: debug_line=#{debug_items}"
    items = DebugItems[debug_items]
    puts "Debug.self.show 2: line=#{items}"
    items.normalize!
    puts "Debug.self.show 3: opts=#{items}"
    puts "Debug.self.show 4: @@outputs=#{@@outputs}"
    @@outputs.each {|output| output.process(items)}
  end
  attr_accessor :class, :method, :note, :vars, :level, :tags
  def initialize(criteria={})
    criteria.each {|k,v| instance_variable_set("@#{k}", v)}
    @@outputs |= [self]
#    puts "Debug.new: @@outputs=#{@@outputs}"
  end
  def process(items)
    # shows items if items satisfy criteria
    catch :done do
      items.each do |k, v|
#        puts "Debug.process 1: v=#{v}"
        ivs = "@#{k}"
        if instance_variable_defined?(ivs)
          iv = instance_variable_get(ivs)
          puts "Debug.process 2: iv=#{iv}"
          puts "Debug.process 3: iv|v=#{iv|v}"
          break if !iv.empty? && (iv|v).empty?
        end
      end
#      puts "Debug.process 4: items=#{items}"
      show(items)
    end
  end
  def show(items)
    puts "Debug.show 1: items=#{items}"
    out = items[:level][0] > 0 ? "#{'^'*items[:level][0]}" : ''
    [:class,:method].each {|item| out += ".#{items[item][0]}" unless items[item].empty?}
    unless items[:note].empty?
      quote = items[:note][0].match(/^[0-9]+$/) ? '' : '"'
      out += " #{quote}#{items[:note][0]}#{quote}"
    end
    out.gsub!(/^(\^*)(\.)(.*)/,'\1\3')
    out.gsub!(/\^/,' ')
    out.gsub!(/^ *$/,'')
    out += ': ' unless out.empty?
    vars = ''
    items[:vars].each { |var| vars += ", #{var[0]}=#{var[1]}" }
    out += vars.gsub(/^, /,'')
    puts "Debug.show 2: out=#{out}"
    puts out
  end
end
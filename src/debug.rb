require 'singleton'

class DebugItems < Hash
  include Singleton
  def normalize!
    add_defaults!
    normalize_context!
    normalize_tags!
    normalize_vars!
    normalize_level!
  end
  def add_defaults!
    {class:nil,method:nil,note:nil,vars:nil,level:nil,tags:nil}.each {|k,v| self[k] = v unless self.has_key?(k)}
  end
  def normalize_context!
    [:class,:method,:note].each do |option|
#      puts "DebugLine.normalize_context! 1: option=#{option}, value=#{self[option]}"
      self[option] = if self[option].kind_of?(Array)
                       self[option].each.map(&:to_s)
                     elsif self[option].nil?
                       []
                     else [self[option].to_s]
                     end
    end
  end
  def normalize_tags!
    tags = self[:tags]
#    puts "DebugLine.normalize_tags! 1: tags=#{tags} is array" if tags.is_a? Array
    self[:tags] = if tags.is_a?(Array)
#                      puts "DebugLine.normalize_tags! 2: tags=#{tags.map(&:to_sym)}"
                      tags.map(&:to_sym)
                  elsif tags.nil? then []
                  else [tags.to_sym]
                  end
  end
  def normalize_vars!
#    puts "DebugLine.normalize_vars! 1: vars=#{self[:vars]}"
    self[:vars] = if self[:vars].kind_of?(Array)
                    if self[:vars][0].kind_of?(Array)
                      self[:vars]
                    elsif self[:vars].size == 2
                      [self[:vars]]
                    else []
                    end
                  else []
                  end
  end
  def normalize_level!
    level = self[:level]
#    puts "DebugLine.normalize_level! 1: level=#{level}"
    level = level[0] if level.kind_of?(Array)
    self[:level] = if level.nil?
                     []
                   elsif !level.is_a? Integer
                     begin
                       [level.to_i]
                     rescue
                       [0]
                     end
                   else [level]
                   end
  end
end

class Debug
  @@outputs = []
  def self.show(debug_items={})
#    puts "Debug.self.show 1: debug_line=#{debug_items}"
    items = DebugItems[debug_items]
#    puts "Debug.self.show 2: line=#{items}"
    items.normalize!
#    puts "Debug.self.show 3: items=#{items}"
#    puts "Debug.self.show 4: @@outputs=#{@@outputs}"
    @@outputs.each {|output| output.process(items)}
  end
  attr_accessor :class, :method, :note, :vars, :level, :tags
  def initialize(criteria={})
    crit = DebugItems[criteria]
    crit.normalize!
    DebugItems[crit].each {|k,v| instance_variable_set("@#{k}", v)}
    @@outputs |= [self]
#    puts "Debug.new: @@outputs=#{@@outputs}"
  end
  def process(items)
    # shows items if items satisfy criteria
    catch :done do
      items.each do |k, v|
#        puts "Debug.process 1: k=#{k}, v=#{v}"
        ivs = "@#{k}"
        if instance_variable_defined?(ivs)
          iv = instance_variable_get(ivs)
#          puts "Debug.process 2: iv=#{iv}"
#          puts "Debug.process 3: iv&v=#{iv&v}"
          if !iv.empty? && (iv&v).empty?
#            puts 'Debug.process 4: throwing done'
            throw :done
          end
        end
      end
#      puts "Debug.process 4: items=#{items}"
      show(items)
    end
  end
  def show(items)
#    puts "Debug.show 1: items=#{items}"
    out = items[:level].empty?||items[:level][0]< 1 ? '' :  "#{'^'*items[:level][0]}"
    [:class,:method].each {|item| out += ".#{items[item][0]}" unless items[item].empty?}
    unless items[:note].empty?
      quote = items[:note][0].match(/^[0-9]+$/) ? '' : '"'
      out += " #{quote}#{items[:note][0]}#{quote}"
    end
#    puts "Debug.show 2: out=#{out}="
    out.gsub!(/^(\^*)(\.)(.*)/,'\1\3')
#    puts "Debug.show 3: out=#{out}="
    out.gsub!(/\^/,' ')
    out += ': ' unless out.match(/^\s*$/)
    vars = ''
    items[:vars].each { |var| vars += ", #{var[0]}=#{var[1]}" }
    out += vars.gsub(/^, /,'')
#    puts "Debug.show 4: out=#{out}"
    puts out
  end
end
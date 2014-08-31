require 'singleton'

class DebugItems < Hash
  include Singleton
  def normalize!(is_output=false)
    add_defaults!
    normalize_contexts!
    normalize_tags!
    is_output ? normalize_context!(:vars) : normalize_vars!
    normalize_levels!
  end
  def add_defaults!
    {class:nil,method:nil,note:nil,vars:nil,level:nil,tags:nil}.each {|k,v| self[k] = v unless self.has_key?(k)}
  end
  def normalize_contexts!; [:class,:method,:note].each {|context| normalize_context!(context)} end
  def normalize_context!(context)
#    puts "DebugLine.normalize_context! 1: context=#{context}, value=#{self[context]}"
    self[context] = if self[context].kind_of?(Array)
                  self[context].each.map(&:to_s)
                elsif self[context].nil?
                  []
                else [self[context].to_s]
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
  def normalize_levels!
    level = self[:level]
    normalize_level = lambda {|l|
      if !l.is_a? Integer
        begin
          l = l.to_i
        rescue
          l = 0
        end
      end
      l
    }
    self[:level] = if level.nil? || level == []
                     []
                   elsif level.is_a? Array
                     level.map {|l| normalize_level.call(l)}
                   else
                     [normalize_level.call(level)]
                   end
  end
end

class Debug
  def self.empty; @@outputs = [] end
  Debug.empty
  def self.outputs; @@outputs end
  def self.show(debug_items={})
#    puts "Debug.self.show 1: debug_line=#{debug_items}"
    items = DebugItems[debug_items]
#    puts "Debug.self.show 2: line=#{items}"
    items.normalize!
#    puts "Debug.self.show 3: items=#{items}"
#    puts "Debug.self.show 4: @@outputs=#{@@outputs}"
    Debug.outputs.each {|output| output.show(items) if output.include?(items)}
  end
  attr_accessor :class, :method, :note, :vars, :level, :tags
  def initialize(criteria={})
    crit = DebugItems[criteria]
    crit.normalize!(true)
    DebugItems[crit].each {|k,v| instance_variable_set("@#{k}", v)}
    @@outputs |= [self]
#    puts "Debug.new: @@outputs=#{@@outputs}"
  end
  def include?(items)
    # include if items satisfy criteria
    catch :done do
      items.each do |k, ov|
        v = k == :vars ? ov.map {|i| i[0]} : ov.clone
#        puts "Debug.include? 1: k=#{k}, v=#{v}"
        ivs = "@#{k}"
        if instance_variable_defined?(ivs)
          iv = instance_variable_get(ivs)
#          puts "Debug.include? 2: iv=#{iv}"
#          puts "Debug.include? 3: iv&v=#{iv&v}"
#          puts "Debug.include? 4: (iv-v).empty?=#{(iv-v).empty?}"
          if !iv.empty? && !(iv-v).empty?
#            puts 'Debug.include? 5: throwing done'
            throw :done
          end
        end
      end
#      puts "Debug.include? 6a: true"
      return true
    end
#    puts "Debug.include? 6b: false"
    false
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
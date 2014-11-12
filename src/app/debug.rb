require_relative 'debug_item'

class Debug
  def self.empty; @@outputs = [] end
  Debug.empty
  def self.outputs; @@outputs end
  def self.show(debug_items={})
#    puts "Debug.self.show 1: debug_line=#{debug_items}"
    items = DebugItem[debug_items]
#    puts "Debug.self.show 2: line=#{items}"
    items.normalize!
#    puts "Debug.self.show 3: items=#{items}"
#    puts "Debug.self.show 4: @@outputs=#{@@outputs}"
    Debug.outputs.each {|output| output.show(items) if output.include?(items)}
  end
  attr_accessor :class, :method, :note, :vars, :level, :tags
  def initialize(criteria={})
    crit = DebugItem[criteria]
    crit.normalize!(true)
    DebugItem[crit].each {|k,v| instance_variable_set("@#{k}", v)}
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
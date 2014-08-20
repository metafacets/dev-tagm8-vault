class Debug
  @@outputs = []
  def self.show(options={})
#    puts "Debug.self.show: @@outputs=#{@@outputs}"
    @@outputs.each do |output|
      output.process(options)
    end
  end
  def self.normalize(options)
    default = {class:nil,method:nil,note:nil,vars:nil,level:0}
    options = default.merge(options)
#    puts "Debug.standardise 1: options=#{options}"
    [:class,:method,:note,:tags].each do |criteria|
      crit = options[criteria]
      options[criteria] = if crit.nil?
                            []
                          elsif crit.kind_of?(Array)
                            each.map {|o| o.to_s}
                          else
                            [crit.to_s]
                          end
    end
#    puts "Debug.standardise 2: options=#{options}"
    vars = if options[:vars].kind_of?(Array)
             if options[:vars][0].kind_of?(Array)
               options[:vars]
             elsif options[:vars].size == 2
               [options[:vars]]
             else
               []
             end
           else
             []
           end
    options[:vars] = vars
    options[:level] = [options[:level]]
#    puts "Debug.standardise 3: options=#{options}"
    options
  end
  attr_accessor :class, :method, :note, :vars, :level
  def initialize(options={})
    options.each {|k,v| instance_variable_set("@#{k}", v)}
    @@outputs |= [self]
#    puts "Debug.new: @@outputs=#{@@outputs}"
  end
  def process(options)
    # options.normalize!
    options = Debug.normalize(options)
    catch :done do
      options.each do |k, v|
#        puts "Debug.process 1: v=#{v}"
        ivs = "@#{k}"
        if instance_variable_defined?(ivs)
          iv = instance_variable_get(ivs)
          puts "Debug.process 2: iv=#{iv}"
          puts "Debug.process 3: iv|v=#{iv|v}"
          break if !iv.empty? && (iv|v).empty?
        end
      end
#      puts "Debug.process 4: options=#{options}"
      show(options)
    end
  end
  def show(options)
    puts "Debug.show 1: options=#{options}"
    out = options[:level][0] > 0 ? "#{'^'*options[:level][0]}" : ''
    [:class,:method].each {|option| out += ".#{options[option][0]}" unless options[option].empty?}
    unless options[:note].empty?
      quote = options[:note][0].match(/^[0-9]+$/) ? '' : '"'
      out += " #{quote}#{options[:note][0]}#{quote}"
    end
    out.gsub!(/^(\^*)(\.)(.*)/,'\1\3')
    out.gsub!(/\^/,' ')
    out.gsub!(/^ *$/,'')
    out += ': ' unless out.empty?
    vars = ''
    options[:vars].each { |var| vars += ", #{var[0]}=#{var[1]}" }
    out += vars.gsub(/^, /,'')
    puts "Debug.show 2: out=#{out}"
    puts out
  end
end
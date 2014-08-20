class Person
  attr_accessor :name, :age
  def initialize(name,age)
    @name=name
    @age=age
  end
  def debug_test
    Debug.show(class:self.class,method:__method__,note:'my note',vars:[['@name',name],['@age',age]])
    temp = 'temp'
    Debug.show(class:self.class,method:__method__,note:'my note',level:0,vars:[['temp',temp],['@name',name],['@age',age]])
  end
end

class Hash;
  def normalize!
    puts "Debug.normalise 0: self=#{self}"
    {class:nil,method:nil,note:nil,vars:nil,level:0}.each {|k,v| self[k] = v unless self.has_key?(k)}
    puts "Debug.normalise 1: self=#{self}"
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
    puts "Options.normalise 2: self=#{self}"
    vars = []
    vars = if vars.kind_of?(Array)
             if self[:vars][0].kind_of?(Array)
               self[:vars]
             elsif self[:vars].size == 2
               [self[:vars]]
             end
           end
    self[:vars] = vars
    self[:level] = [self[:level]]
    puts "Options.normalise 3: self=#{self}"
  end
end

class Debug
  @@outputs = []
  def self.show(options={})
    puts "Debug.self.show: @@outputs=#{@@outputs}"
    @@outputs.each do |output|
      output.process(options)
    end
  end
  attr_accessor :class, :method, :note, :vars, :level
  def initialize(options={})
    options.each {|k,v| instance_variable_set("@#{k}", v)}
    @@outputs |= [self]
    puts "Debug.new: @@outputs=#{@@outputs}"
  end
  def normalize(options)
    default = {class:nil,method:nil,note:nil,vars:nil,level:0}
    options = default.merge(options)
    puts "Debug.standardise 1: options=#{options}"
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
    puts "Debug.standardise 2: options=#{options}"
    vars = []
    vars = if vars.kind_of?(Array)
             if options[:vars][0].kind_of?(Array)
               options[:vars]
             elsif options[:vars].size == 2
               [options[:vars]]
             end
           end
    options[:vars] = vars
    options[:level] = [options[:level]]
    puts "Debug.standardise 3: options=#{options}"
    options
  end
  def process(options)
    # options.normalize!
    options = normalize(options)
    catch :done do
      options.each do |k, v|
        puts "Debug.process 1: v=#{v}"
        ivs = "@#{k}"
        if instance_variable_defined?(ivs)
          iv = instance_variable_get(ivs)
          puts "Debug.process 2: iv=#{iv}"
          puts "Debug.process 3: iv|v=#{iv|v}"
          break if !iv.empty? && (iv|v).empty?
        end
      end
      puts "Debug.process 4: options=#{options}"
      show(options)
    end
  end
  def show(options)
    puts "Debug.show 1: options=#{options}"
    out = options[:level][0] > 0 ? "#{'  '*options[:level][0]}" : ''
    [:class,:method,:note].each do |option|
      out += ", #{option.to_s}=#{options[option][0]}" if options[option]
    end
    options[:vars].each { |var| out += ", #{var[0]}=#{var[1]}" }
    puts "Debug.show 2: out=#{out}"
  end
end

d = Debug.new class:['Person'],method:['debug_test']
#d = Debug.new
#d.class = :Person
puts "d=#{d}"
p = Person.new('Jack',25)
p.debug_test

require 'singleton'

class DebugItem < Hash
  include Singleton
  def normalize!(is_output=false)
    add_defaults!
    normalize_contexts!
    normalize_tags!
    normalize_vars!(is_output)
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
  def normalize_vars!(is_output=false)
#    puts "DebugLine.normalize_vars! 1: vars=#{self[:vars]}"
    if is_output
      normalize_context!(:vars)
    else
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


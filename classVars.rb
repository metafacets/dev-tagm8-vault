class Tag
  @@tags = {}
  @@roots = []        # maintain for changes -> add_parent method?
  @@folksonomy = []   # test

  def self.tags
    @@tags
  end

  def initialize(name, parent, child)
    @name = name
    @@tags[name] = self
    @parent = parent
    @child = [child]
    if parent.nil? && !child.nil?
      @@roots += [name]
    end
    if child.nil? && parent.nil?
      @@folksonomy += [name]
    end
  end

  def has_parent?
    !@parent.nil?
  end

  def add_child(child)
    @child += [child] if !@child.include?(child)
    if @@folksonomy.include?(child)
      @@folksonomy.delete(child)
    elsif @@roots.include?(child)
      @@roots.delete(child)
    end
  end

  def add_parent(parent)
    @parent = parent if @parent.nil?
    if @@tags[parent].has_parent?
      @@roots.delete(parent) if @@roots.include?(parent)
      else
        @@roots += [parent] if !@@roots.include?(parent)
        @@folksonomy.delete(parent) if @@folksonomy.include?(parent)
    end
  end

  def self.add_tag(name, options={})
    defaults = {:parent => nil, :child => nil}
    options = defaults.merge(options)
    Tag.new(name, options[:parent], options[:child]) if !@@tags.has_key?(name)
    if !options[:parent].nil?
      if !@@tags.has_key?(options[:parent])
        Tag.new(options[:parent], nil, name)
      else
        @@tags[name].add_parent(options[:parent])
        @@tags[options[:parent]].add_child(name)
      end
    end
  end

end

Tag.methods
options = {parent: :mammal}
Tag.add_tag(:cat, options)
Tag.add_tag(:dog, options)
options = {parent: :animal}
Tag.add_tag(:mammal, options)
puts Tag.tags
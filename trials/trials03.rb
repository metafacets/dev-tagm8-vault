class Item
  def name=(name) @name = name end
  def name; @name end
  def set_name(name)
    self.name = name
  end
end

i = Item.new
i.set_name('Fred')
puts i.name
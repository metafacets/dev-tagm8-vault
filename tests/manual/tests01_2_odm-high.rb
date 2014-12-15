require_relative '../../src/app/debug'
require_relative '../../src/app/tag_2_odm-high'

MongoMapper.connection.drop_database('tagm8')
tax = Taxonomy.new(name:'Tax')
a = tax.get_lazy_tag(:a)
puts "a=#{a}"
#tax.add_tag(:c,:p)
tax.get_lazy_tag(:a)
puts "tax.tags=#{tax.tags}"
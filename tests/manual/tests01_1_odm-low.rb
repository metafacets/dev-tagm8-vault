require_relative '../../src/app/debug'
require_relative '../../src/app/tag_1_odm-low'

MongoMapper.connection.drop_database('tagm8')
tax = Taxonomy.new(name:'Tax')
a = tax.get_lazy_tag(:a)
puts "a=#{a}"
#tax.add_tag(:c,:p)
tax.get_lazy_tag(:a)
puts "tax.tags=#{tax.tags}, tax.dag_prevent?=#{tax.dag_prevent?}"
tax.dag_fix
puts "tax.dag_prevent?=#{tax.dag_prevent?}"
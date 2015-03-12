require 'rspec'
require_relative '../../src/app/item'

describe Item do
  context 'class methods' do
    MongoMapper.connection.drop_database('tagm8')
    tax1 = Taxonomy.new('tax1')
    tax2 = Taxonomy.new('tax2')
    alm1 = tax1.add_album('alm1')
    alm2 = tax1.add_album('alm2')
    tax2.add_album('alm3')
    alm1_exists = Album.exists?(name='alm1')
    alm4_exists = Album.exists?(name='alm4')
    tax1_has_alm1 = tax1.has_album?(name='alm1')
    tax1_has_alm3 = tax1.has_album?(name='alm3')
    oalm1 = Album.open('alm1')
    oalm4 = Album.open('alm4')
#    lalm1 = Album.lazy('alm1')
#    lalm4 = Album.lazy('alm4')
    count_alm = Album.count
    tax1_count_alm = tax1.count_albums
    list_alm = Album.list.sort
    tax1_list_alm = tax1.list_albums.sort
    alm1.add_item('i1')
    alm1.add_item('i2')
    alm2.add_item('i3')
    count_items = Item.count
    list_items = Item.list.sort
    i1_exists = Item.exists?('i1')
    i4_exists = Item.exists?('i4')
    alm1_has_i1 = alm1.has_item?('i1')
    alm1_has_i3 = alm1.has_item?('i3')
    alm1_count_items = alm1.count_items
    alm1_list_items = alm1.list_items.sort
    it 'existent Album :exists?' do expect(alm1_exists).to be_truthy end
    it 'non-existent Album not :exists?' do expect(alm4_exists).to be_falsey end
    it 'Album :open existing' do expect(oalm1._id).to eq(alm1.id) end
    it 'Album :open non-existent' do expect(oalm4).to be_nil end
#    it ':lazy existing' do expect(lalm1._id).to eq(alm1.id) end
#    it ':lazy non-existant' do expect(lalm4.name).to eq('alm4') end
    it 'Album :count' do expect(count_alm).to eq(3) end
    it 'tax1 :count_albums' do expect(tax1_count_alm).to eq(2) end
    it 'Album :list' do expect(list_alm).to eq(['alm1','alm2','alm3']) end
    it 'tax1 :list_albums' do expect(tax1_list_alm).to eq(['alm1','alm2']) end
    it 'tax1 has existent album' do expect(tax1_has_alm1).to be_truthy end
    it 'tax1 does not have non-existent album' do expect(tax1_has_alm3).to be_falsey end
    it 'Item :count' do expect(count_items).to eq(3) end
    it 'Item :list' do expect(list_items).to eq(['i1','i2','i3']) end
    it 'existent Item :exists?' do expect(i1_exists).to be_truthy end
    it 'non-existent Item not :exists?' do expect(i4_exists).to be_falsey end
    it 'alm1 has existent album' do expect(alm1_has_i1).to be_truthy end
    it 'alm1 does not have non-existent album' do expect(alm1_has_i3).to be_falsey end
    it 'alm1 :count_items' do expect(alm1_count_items).to eq(2) end
    it 'alm1 :count_items' do expect(alm1_count_items).to eq(2) end
    it 'alm1 :list_items' do expect(alm1_list_items).to eq(['i1','i2']) end
  end
  describe 'instance methods' do
    MongoMapper.connection.drop_database('tagm8')
    tax = Taxonomy.new
    alm = tax.add_album('alm')
    item = alm.add_item('i1')
    subject {item}
    methods = [:date, :name, :content, :tags, :sees, :instantiate, :parse, :parse_entry, :parse_content]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
  end
  describe :initialize do
    # test = [[entry,name,content,tags,tax.tags]]
    tests = [["Name\nContent","Name","Content",[],[],[]]\
            ,["Name\nContent\ncont","Name","Content\ncont",[],[]]\
            ,["Name\n#a Content","Name","#a Content",[:a],[:a]]\
            ,["Name\nContent #a","Name","Content #a",[:a],[:a]]\
            ,["Name\nContent #:a","Name","Content #:a",[:a],[:a]]\
            ,["Name\nContent =#a","Name","Content =#a",[:a],[:a]]\
            ,["Name\nContent =#:a","Name","Content =#:a",[:a],[:a]]\
            ,["Name\nContent +#a","Name","Content +#a",[],[:a]]\
            ,["Name\nContent +#:a","Name","Content +#:a",[],[:a]]\
            ,["Name\nContent\n#a","Name","Content\n#a",[:a],[:a]]\
            ,["Name\nContent\ncont #a","Name","Content\ncont #a",[:a],[:a]]\
            ,["Name\nContent\n#a cont","Name","Content\n#a cont",[:a],[:a]]\
            ,["Name\nContent #a #b","Name","Content #a #b",[:a,:b],[:a,:b]]\
            ,["Name\nContent #a\n#b","Name","Content #a\n#b",[:a,:b],[:a,:b]]\
            ,["Name\nContent #:a<:b\ncont","Name","Content #:a<:b\ncont",[:a],[:a,:b]]\
            ,["Name\nContent =#:a<:b\ncont","Name","Content =#:a<:b\ncont",[:a],[:a,:b]]\
            ,["Name\nContent +#:a<:b\ncont","Name","Content +#:a<:b\ncont",[],[:a,:b]]\
            ,["Name\nContent #:a>[:b,:c>[:d,:e]]\ncont","Name","Content #:a>[:b,:c>[:d,:e]]\ncont",[:b,:d,:e],[:a,:b,:c,:d,:e]]\
            ,["Name\nContent #:a>[:b,:c>[:d,:e]]\ncont #a,b,f","Name","Content #:a>[:b,:c>[:d,:e]]\ncont #a,b,f",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\nContent #a,b,f\ncont #:a>[:b,:c>[:d,:e]]","Name","Content #a,b,f\ncont #:a>[:b,:c>[:d,:e]]",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\nContent #:a>[:b,:c>[:d,:e]]\ncont #a #b,f","Name","Content #:a>[:b,:c>[:d,:e]]\ncont #a #b,f",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\nContent #:a>[:b,:c>[:d,:e]]\ncont #a #b,f","Name","Content #:a>[:b,:c>[:d,:e]]\ncont #a #b,f",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\n#a Content #:a>[:b,:c>[:d,:e]]\ncont #b,f","Name","#a Content #:a>[:b,:c>[:d,:e]]\ncont #b,f",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\n#b,f Content #:a>[:b,:c>[:d,:e]]\ncont #a","Name","#b,f Content #:a>[:b,:c>[:d,:e]]\ncont #a",[:a,:b,:d,:e,:f],[:a,:b,:c,:d,:e,:f]]\
            ,["Name\n#b,f Content #:a>[:b,:c>[:d,:e]]\ncont #a -#f,b,c","Name","#b,f Content #:a>[:b,:c>[:d,:e]]\ncont #a -#f,b,c",[:a,:d,:e],[:a,:d,:e]]\
            ]
    tests.each do |test|
      describe test[0] do
        describe :parse_entry do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = Item.new(alm)
          item.parse_entry(test[0])
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
        end
        describe :parse_content do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = Item.new(alm)
          item.name = test[1]
          item.content = test[2]
          item.parse_content
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
        end
        describe :parse do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = Item.new(alm)
          item.parse(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.map {|tag| tag.name.to_sym}.sort
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
        end
        describe :instantiate do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = Item.new(alm)
          item.instantiate(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.map {|tag| tag.name.to_sym}.sort
          items = alm.items.map {|i| i.name}
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
          it "items = ['Name']" do expect(items).to eq(['Name']) end
        end
        describe :initialize do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = alm.add_item(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.map {|tag| tag.name.to_sym}.sort
          items = alm.items.map {|i| i.name}
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
          it "items = ['Name']" do expect(items).to eq(['Name']) end
        end
        describe :query_tags do
          MongoMapper.connection.drop_database('tagm8')
          tax = Taxonomy.new
          alm = tax.add_album('alm')
          item = alm.add_item(test[0])
          queried_tags = item.query_tags.map {|tag| tag.name.to_sym}.sort
          it "query_tags = #{test[3]}" do expect(queried_tags).to eq(test[3]) end
        end
      end
    end
  end
end
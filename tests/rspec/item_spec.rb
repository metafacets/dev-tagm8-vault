require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\item.rb'

describe Item do
  describe 'instance methods' do
    item = Item.new
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
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new
          item.parse_entry(test[0])
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
        end
        describe :parse_content do
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new
          item.name = test[1]
          item.content = test[2]
          item.parse_content
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
        end
        describe :parse do
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new
          item.parse(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.keys.sort
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
        end
        describe :instantiate do
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new
          item.instantiate(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.keys.sort
          items = Item.items.map {|i| i.name}
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
          it "items = ['Name']" do expect(items).to eq(['Name']) end
        end
        describe :initialize do
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new(test[0])
          item_tags = item.tags.map {|tag| tag.name.to_sym}.sort
          tax_tags = tax.tags.keys.sort
          items = Item.items.map {|i| i.name}
          it "name = #{test[1]}" do expect(item.name).to eq(test[1]) end
          it "content = #{test[2]}" do expect(item.content).to eq(test[2]) end
          it "tags = #{test[3]}" do expect(item_tags).to eq(test[3]) end
          it "Taxonomy.tags = #{test[4]}" do expect(tax_tags).to eq(test[4]) end
          it "items = ['Name']" do expect(items).to eq(['Name']) end
        end
        describe :query_tags do
          tax = Taxonomy.new
          Item.taxonomy = tax
          Item.items = []
          item = Item.new(test[0])
          queried_tags = item.query_tags.map {|tag| tag.name.to_sym}.sort
          it "query_tags = #{test[3]}" do expect(queried_tags).to eq(test[3]) end
        end
      end
    end
  end
end
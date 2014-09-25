require 'rspec'
require 'facets'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\ddl.rb'

describe Ddl do
  describe 'instance methods' do
    subject {Ddl}
    methods = [:raw_ddl=, :raw_ddl, :pre_ddl=, :pre_ddl, :ddl=, :ddl, :tags=, :tags, :has_tags?, :links=, :links,:leaves=,:leaves, :parse, :prepare, :process, :extract_structure, :extract_leaves, :pre_process, :fix_errors, :wipe]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
  end
  describe :extract_structure do
    # pairs = [tag_ddl,ddl,tags,links]
    tests = [[':a',[:a],[:a],[]]\
            ,[':a,:b',[:a,:b],[:a,:b],[]]\
            ,[':a<:b',[:a,"<",:b],[:a,:b],[[[:a],[:b]]]]\
            ,[':a1<:b>a2',[:a1,"<",:b,">",:a2],[:a1,:a2,:b],[[[:a2],[:b]],[[:a1],[:b]]]]\
            ,[':a1>:b<a2',[:a1,">",:b,"<",:a2],[:a1,:a2,:b],[[[:b],[:a2]],[[:b],[:a1]]]]\
            ,['[:a1,:a2]<:b',[[:a1,:a2],"<",:b],[:a1,:a2,:b],[[[:a2,:a1],[:b]]]]\
            ,['[:a1,:a2]<:b>[:a3,:a4]',[[:a1,:a2],"<",:b,">",[:a3,:a4]],[:a1,:a2,:a3,:a4,:b],[[[:a4,:a3],[:b]],[[:a2,:a1],[:b]]]]\
            ,['[:a1,:a2]<:b>[:a3,:a4>[:c1,:c2]',[[:a1,:a2],"<",:b,">",[:a3,:a4,">",[:c1,:c2]]],[:a1,:a2,:a3,:a4,:b,:c1,:c2],[[[:c2,:c1],[:a4]],[[:a4,:a3],[:b]],[[:a2,:a1],[:b]]]]\
            ]
    tests.each do |test|
      describe test[0] do
        Ddl.wipe
        Ddl.extract_structure(test[1])
        tags_ok = (Ddl.tags&test[2]).sort == test[2]
        links_ok = (Ddl.links&test[3]) == test[3]
        it "tags = #{test[2]}" do expect(tags_ok).to be true end
        it "links = #{test[3]}" do expect(links_ok).to be true end
#        puts"tags:  expected=#{test[2]}, got=#{Ddl.tags}"
#        puts"links: expected=#{test[3]}, got=#{Ddl.links}"
      end
    end
  end
  describe :extract_leaves do
    # pairs = [tag_ddl,tags,links,leaves]
    tests = [[':a',[:a],[],[:a]]\
            ,[':a,:b',[:a,:b],[],[:a,:b]]\
            ,[':a<:b',[:a,:b],[[[:a],[:b]]],[:a]]\
            ,[':a1<:b>a2',[:a1,:a2,:b],[[[:a1],[:b]],[[:a2],[:b]]],[:a1,:a2]]\
            ,[':a1>:b<a2',[:a1,:a2,:b],[[[:b],[:a1]],[[:b],[:a2]]],[:b]]\
            ,['[:a1,:a2]<:b',[:a1,:a2,:b],[[[:a1,:a2],[:b]]],[:a1,:a2]]\
            ,['[:a1,:a2]<:b>[:a3,:a4]',[:a1,:a2,:a3,:a4,:b],[[[:a1,:a2],[:b]],[[:a3,:a4],[:b]]],[:a1,:a2,:a3,:a4]]\
            ,['[:a1,:a2]<:b>[:a3,:a4>[:c1,:c2]',[:a1,:a2,:a3,:a4,:b,:c1,:c2],[[[:a1,:a2],[:b]],[[:a3,:a4],[:b]],[[:c1,:c2],[:a4]]],[:a1,:a2,:a3,:c1,:c2]]\
            ]
    tests.each do |test|
      describe test[0] do
        Ddl.wipe
        Ddl.tags = test[1]
        Ddl.links = test[2]
        Ddl.extract_leaves
        leaves_ok = Ddl.leaves&test[3] == test[3]
        it "leaves = #{test[3]}" do expect(leaves_ok).to be true end
      end
    end
  end
end
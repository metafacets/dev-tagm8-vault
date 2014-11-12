require 'rspec'
require 'facets'
require_relative '../../src/app/ddl'

describe Ddl do
  describe 'instance methods' do
    subject {Ddl}
    methods = [:raw_ddl=, :raw_ddl, :pre_ddl=, :pre_ddl, :ddl=, :ddl, :tags=, :tags, :has_tags?, :links=, :links,:leaves=,:leaves, :parse, :prepare, :process, :get_structure, :get_leaves, :pre_process, :fix_errors, :wipe]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
  end
  describe :parse do
    # tests = [tag_ddl,ddl,tags,links,leaves]
    tests = [[':a',[:a],[:a],[],[:a]]\
            ,[':a,:b',[:a,:b],[:a,:b],[],[:a,:b]]\
            ,[':a<:b',[:a,"<",:b],[:a,:b],[[[:a],[:b]]],[:a]]\
            ,[':a1<:b>a2',[:a1,"<",:b,">",:a2],[:a1,:a2,:b],[[[:a2],[:b]],[[:a1],[:b]]],[:a1,:a2]]\
            ,[':a1>:b<a2',[:a1,">",:b,"<",:a2],[:a1,:a2,:b],[[[:b],[:a2]],[[:b],[:a1]]],[:b]]\
            ,['[:a1,:a2]<:b',[[:a1,:a2],"<",:b],[:a1,:a2,:b],[[[:a2,:a1],[:b]]],[:a1,:a2]]\
            ,['[:a1,:a2]<:b>[:a3,:a4]',[[:a1,:a2],"<",:b,">",[:a3,:a4]],[:a1,:a2,:a3,:a4,:b],[[[:a4,:a3],[:b]],[[:a2,:a1],[:b]]],[:a1,:a2,:a3,:a4]]\
            ,['[:a1,:a2]<:b>[:a3,:a4>[:c1,:c2]]',[[:a1,:a2],"<",:b,">",[:a3,:a4,">",[:c1,:c2]]],[:a1,:a2,:a3,:a4,:b,:c1,:c2],[[[:c2,:c1],[:a4]],[[:a4,:a3],[:b]],[[:a2,:a1],[:b]]],[:a1,:a2,:a3,:c1,:c2]]\
            ]
    tests.each do |test|
      describe test[0] do
        describe :prepare do
          Ddl.wipe
          Ddl.raw_ddl = test[0]
          Ddl.prepare
          ddl_ok = (Ddl.ddl&test[1]) == test[1]
          # puts"ddl: expected=#{test[1]}, got=#{Ddl.ddl}, ddl_test=#{Ddl.ddl&test[1]}"
          it "ddl = #{test[1]}" do expect(ddl_ok).to be true end
        end
        describe :extract_structure do
          Ddl.wipe
          Ddl.get_structure(test[1])
          tags_ok = (Ddl.tags&test[2]).sort == test[2]
          links_ok = (Ddl.links&test[3]) == test[3]
          it "tags = #{test[2]}" do expect(tags_ok).to be true end
          it "links = #{test[3]}" do expect(links_ok).to be true end
          # puts"tags:  expected=#{test[2]}, got=#{Ddl.tags}"
          # puts"links: expected=#{test[3]}, got=#{Ddl.links}"
        end
        describe :extract_leaves do
          Ddl.wipe
          Ddl.tags = test[2]
          Ddl.links = test[3]
          Ddl.get_leaves
          leaves_ok = (Ddl.leaves&test[4]).sort == test[4]
          # puts"leaves: expected=#{test[4]}, got=#{Ddl.leaves}, leaves_test=#{(Ddl.leaves&test[4]).sort}"
          it "leaves = #{test[4]}" do expect(leaves_ok).to be true end
        end
        describe :parse do
          Ddl.wipe
          Ddl.parse(test[0])
          raw_ddl_ok = Ddl.raw_ddl == test[0]
          ddl_ok = (Ddl.ddl&test[1]) == test[1]
          tags_ok = (Ddl.tags&test[2]).sort == test[2]
          links_ok = (Ddl.links&test[3]) == test[3]
          leaves_ok = (Ddl.leaves&test[4]).sort == test[4]
          it "raw_ddl = #{test[0]}" do expect(raw_ddl_ok).to be true end
          it "ddl = #{test[1]}" do expect(ddl_ok).to be true end
          it "tags = #{test[2]}" do expect(tags_ok).to be true end
          it "links = #{test[3]}" do expect(links_ok).to be true end
          it "leaves = #{test[4]}" do expect(leaves_ok).to be true end
        end
      end
    end
  end
end
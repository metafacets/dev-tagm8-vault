require 'rspec'
require_relative '../../src/app/debug'

describe Debug do
  context :include? do
    #sets = [output_criteria,line_criteria,expected]
    sets = [[[],[],true]\
           ,[[],['a'],true]\
           ,[['a'],[],false]\
           ,[['a'],['b'],false]\
           ,[['a'],['a'],true]\
           ,[['a','b'],['a'],false]\
           ,[['a','b'],['a','b'],true]\
           ,[['a','b'],['a','b','c'],true]\
           ]
    items = [:class,:method,:note]
    items.each do |item|
      context "#{item}" do
        sets.each do |set|
          Debug.empty
          d = Debug.new(item => set[0])
#          puts "test: d=#{d},item=#{item}=>#{set[1]},expected=#{set[2]},got=#{d.include?(item => set[1])},#{d.include?(item => set[1])}==#{set[2]}=#{eval("#{d.include?(item => set[1])}==#{set[2]}")}"
          s = d.include?(item => set[1])
          e = set[2]
#          puts "test: got=#{s}, expected=#{set[2]}"
          it "#{set[1]} includes #{set[0]} is #{set[2].to_s}" do expect(s).to eq(e) end
        end
      end
    end
    context 'tags' do
      sets = [[[],[],true]\
           ,[[],[:a],true]\
           ,[[:a],[],false]\
           ,[[:a],[:b],false]\
           ,[[:a],[:a],true]\
           ,[[:a,:b],[:a],false]\
           ,[[:a,:b],[:a,:b],true]\
           ,[[:a,:b],[:a,:b,:c],true]\
           ]
      sets.each do |set|
        Debug.empty
        d = Debug.new(:tags => set[0])
        s = d.include?(:tags => set[1])
        e = set[2]
#        puts "test: got=#{s}, expected=#{set[2]}"
        it "#{set[1]} includes #{set[0]} is #{set[2].to_s}" do expect(s).to eq(e) end
      end
    end
    context 'levels' do
      sets = [[[],[],true]\
           ,[[],[1],true]\
           ,[[1],[],false]\
           ,[[1],[2],false]\
           ,[[1],[1],true]\
           ,[[1,2],[1],false]\
           ,[[1,2],[1,2],true]\
           ,[[1,2],[1,2,3],true]\
           ]
      sets.each do |set|
        Debug.empty
        d = Debug.new(:levels => set[0])
        s = d.include?(:levels => set[1])
        e = set[2]
#        puts "test: got=#{s}, expected=#{set[2]}"
        it "#{set[1]} includes #{set[0]} is #{set[2].to_s}" do expect(s).to eq(e) end
      end
    end
    context 'vars' do
      sets = [[[],[],true]\
           ,[[],[['i1','v1']],true]\
           ,[['i1'],[],false]\
           ,[['i1'],[['i2','v2']],false]\
           ,[['i1'],[['i1','v1']],true]\
           ,[['i1','i2'],[['i1','v1']],false]\
           ,[['i1','i2'],[['i1','v1'],['i2','v2']],true]\
           ,[['i1','i2'],[['i1','v1'],['i2','v2'],['i3','v3']],true]\
           ]
      sets.each do |set|
        Debug.empty
        d = Debug.new(:vars => set[0])
        s = d.include?(:vars => set[1])
        e = set[2]
#        puts "test: got=#{s}, expected=#{set[2]}"
        it "#{set[1]} includes #{set[0]} is #{set[2].to_s}" do expect(s).to eq(e) end
      end
    end
  end
end

require 'rspec'
require_relative '../../src/app/debug'

describe DebugItem do
  context 'instance methods' do
    subject {DebugItem[{}]}
    methods = [:normalize!,:add_defaults!,:normalize_contexts!,:normalize_tags!,:normalize_vars!,:normalize_levels!]
    methods.each { |method| it method do expect(subject).to respond_to(method) end }
  end
  context :add_defaults! do
    items = [:class,:method,:note,:tags,:vars,:level]
    context '{} supplied' do
      subject {DebugItem[{}].add_defaults!}
      items.each { |item| it "#{item} nil" do expect(subject).to include(item => nil) end }
    end
    supplied_args = [{class:'Tag',method:'foo'},{note:1,level:2},{tags:['t1,t2']},{vars:[['v1','val1'],['v2','val2']]}]
#    puts "@supplied_args=#{supplied_args}"
    supplied_args.each do |supplied_arg|
#      puts "(items-supplied_arg.keys)=#{(items-supplied_arg.keys)}"
      default_items = Hash[*(items-supplied_arg.keys).map {|k| [k, nil]}.flatten]
#      puts "default_items=#{default_items}, supplied_arg=#{supplied_arg}"
      context "#{supplied_arg} supplied" do
        d = DebugItem[supplied_arg]
        d.add_defaults!
#        puts "d=#{d}, supplied_arg=#{supplied_arg}"
        subject {d}
        it "includes #{supplied_arg}" do expect(subject).to include(supplied_arg) end
        it "includes #{default_items}" do expect(subject).to include(default_items) end
      end
    end
  end
  context :normalize_contexts! do
    pairs = [[nil,[]]\
            ,['val',['val']]\
            ,[[],[]]\
            ,[['val'],['val']]]
    [:class,:method,:note].each do |option|
      context option do
        pairs.each do |pair|
          d = DebugItem[{option=>pair[0]}]
          d.add_defaults!
          d.normalize_contexts!
          expected = {option=>pair[1]}
#          puts "in=#{pair[0]}, d=#{d},expected=#{expected}"
          it "#{pair[0]} becomes #{pair[1]}" do expect(d).to include(expected) end
        end
      end
    end
  end
  context :normalize_tags! do
    pairs = [[nil,[]]\
            ,['val',[:val]]\
            ,[:val,[:val]]\
            ,[[],[]]\
            ,[['val1',:val2]\
            ,[:val1,:val2]]\
            ]
    pairs.each do |pair|
      d = DebugItem[{:tags=>pair[0]}]
      d.add_defaults!
      d.normalize_tags!
      expected = {:tags=>pair[1]}
#      puts "in=#{pair[0]}, d=#{d},expected=#{expected}"
      it "#{pair[0]} becomes #{pair[1]}" do expect(d).to include(expected) end
    end
  end
  context :normalize_vars! do
    pairs = [[nil,[]]\
            ,[[],[]]\
            ,[['a'],[]]\
            ,[['i','v'],[['i','v']]]\
            ,[[['i1','v1'],['i2','v2']],[['i1','v1'],['i2','v2']]]\
            ]
    pairs.each do |pair|
      d = DebugItem[{:vars=>pair[0]}]
      d.add_defaults!
      d.normalize_vars!
      expected = {:vars=>pair[1]}
#          puts "in=#{pair[0]}, d=#{d},expected=#{expected}"
      it "#{pair[0]} becomes #{pair[1]}" do expect(d).to include(expected) end
    end
  end
  context ':normalize_vars! (for outputs)' do
    pairs = [[nil,[]]\
            ,[[],[]]\
            ,[['i1'],['i1']]\
            ,[['i1','i2'],['i1','i2']]\
            ]
    pairs.each do |pair|
      d = DebugItem[{:vars=>pair[0]}]
      d.add_defaults!
      d.normalize_vars!(true)
      expected = {:vars=>pair[1]}
#          puts "in=#{pair[0]}, d=#{d},expected=#{expected}"
      it "#{pair[0]} becomes #{pair[1]}" do expect(d).to include(expected) end
    end
  end
  context :normalize_levels! do
    pairs = [[nil,[]]\
            ,[[],[]]\
            ,[1,[1]]\
            ,['1',[1]]\
            ,['x',[0]]\
            ,[[1],[1]]\
            ,[['1'],[1]]\
            ,[['x'],[0]]\
            ,[[1,2],[1,2]]\
            ,[[1,'2'],[1,2]]\
            ,[[1,'x','2'],[1,0,2]]\
            ]
    pairs.each do |pair|
      d = DebugItem[{:level=>pair[0]}]
      d.add_defaults!
      d.normalize_levels!
      expected = {:level=>pair[1]}
#      puts "in=#{pair[0]}, d=#{d},expected=#{expected}"
      it "#{pair[0]} becomes #{pair[1]}" do expect(d).to include(expected) end
    end
  end
end

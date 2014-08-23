require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\debug.rb'

describe DebugItems do
  context 'instance methods' do
    subject {DebugItems[{}]}
    methods = [:normalize!,:add_defaults!,:normalize_context!,:normalize_tags!,:normalize_vars!,:normalize_level!]
    methods.each { |method| it method do expect(subject).to respond_to(method) end }
  end
  context :add_defaults! do
    subject {DebugItems[{}].add_defaults!}
    items = [:class,:method,:note,:tags,:vars,:level]
    items.each { |item| it "#{item} included" do expect(subject).to include(item => nil) end }
  end
end

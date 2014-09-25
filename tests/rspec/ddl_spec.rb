require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\src\ddl.rb'

describe Ddl do
  context 'instance methods' do
    subject {Ddl}
    methods = [:raw_ddl=, :raw_ddl, :pre_ddl=, :pre_ddl, :ddl=, :ddl, :tags=, :tags, :has_tags?, :links=, :links,:leaves=,:leaves, :parse, :prepare, :process, :extract_structure, :extract_leaves, :pre_process, :fix_errors, :wipe]
    methods.each {|method| it method do expect(subject).to respond_to(method) end }
  end

end
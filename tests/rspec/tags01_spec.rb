require 'rspec'
require 'C:\Users\anthony\Documents\My Workspaces\RubyMine\tagm8\tags01.rb'

describe 'Tag' do

  it 'should initialise' do
    tag = Tag.new(:mammal)
    puts tag.class
  end
end
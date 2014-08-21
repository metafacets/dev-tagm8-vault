catch (:done) do
  5.times do |i|
    5.times do |j|
      puts "i=#{i}, j= #{j}"
      throw :done if i+j > 5
    end
  end
  puts "loop end"
end

class Options < Hash;
  def adapt
    each {|k,v| self[k] = [v]}
  end
end

class Hash;
  def normalise
    each {|k,v| self[k] = [v]}
  end
end
options = Options[{class:'class',method:'method'}]
puts options.adapt
puts "#{{class:'class',method:'method'}.normalise}"

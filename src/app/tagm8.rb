require_relative 'facade'
require 'drb'

Tagm8Db.open('tagm8-app')
DRb.start_service('druby://127.0.0.1:61664',Facade.instance)
puts 'Listening for connection'
DRb.thread.join



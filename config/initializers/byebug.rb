# config/initializers/byebug.rb

if Rails.env.development? and ENV['BYEBUGPORT']
  require 'byebug/core'
  #Byebug.wait_connection = true
  Byebug.start_server 'localhost', ENV['BYEBUGPORT'].to_i
end
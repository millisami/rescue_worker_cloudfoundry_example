require 'sinatra'
require 'rack'

server = ::Rack::Server.new()
server.instance_variable_set('@config', 'config.ru' )
server.start

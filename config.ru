require 'bundler/setup'
require 'resque'
require 'resque/server'
require File.join(File.dirname(__FILE__), 'worker')

#use Rack::ShowExceptions

# Set the AUTH env variable to your basic auth password to protect Resque.
# AUTH_USERNAME = ENV['USERNAME']
# AUTH_PASSWORD = ENV['PASSWORD']

AUTH_USERNAME = "xxx"
AUTH_PASSWORD = "xxx"
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD && username == AUTH_USERNAME
  end

  Worker::App.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD && username == AUTH_USERNAME
  end
end

#disable :run

# Mount the Worker App with a base url of /
map "/" do
  run Worker::App
end

# Mount Resque Web at /resque
map "/resque" do
  run Resque::Server
end

at_exit do
  Worker::App.shutdownall
end

require 'sinatra/base'
require 'json'
require 'mongo_mapper'

# JOBS
require File.join(File.dirname(__FILE__), 'jobs', 'update_profile'  )
require File.join(File.dirname(__FILE__), 'jobs', 'email_sent_count')
require File.join(File.dirname(__FILE__), 'jobs', 'join_stuff'   )
require File.join(File.dirname(__FILE__), 'jobs', 'email_it'   )
require File.join(File.dirname(__FILE__), 'jobs', 'research')

#libs
require File.join(File.dirname(__FILE__), 'lib', 'mailer')
require File.join(File.dirname(__FILE__), 'lib', 'worker_miner')

module Resque
  class Worker
    def register_signal_handlers
      return true
    end
  end
end

class Profile
  include MongoMapper::Document

  key :full_name,              String
  key :email,                  String
  key :some_field,                String
  key :profile_id,             ObjectId

  timestamps!
  
end


module Worker
  class App < Sinatra::Base

    def self.add_worker(queues)
      @@threads << Thread.new do
        puts "Adding worker. Queues: #{queues}"
        worker = Resque::Worker.new(*queues)
        @@workers << worker
        worker.work(ENV['INTERVAL'] || 5)
        puts "Worker finshed. Queues: #{queues}"
      end
    end

    def self.shutdownall
      puts "Shutting down all workers."
      @@workers.each { |worker| worker.shutdown }
      puts "Joining worker threads."
      @@threads.each { |thread| thread.join }
      puts "Finished shutting down."
    end

    def self.configure_redis
      if ENV['VCAP_SERVICES'].nil?
        WorkerMiner.set_redis(Redis.new)
        Resque.redis = Redis.new
      else
        vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
        redis = vcap_services.detect { |k,v| k =~ /redis/ }.last.first

        redis_host      = redis["credentials"]["hostname"]
        redis_port      = redis["credentials"]["port"]
        redis_password  = redis["credentials"]["password"]

        WorkerMiner.set_redis(Redis.new( :host => redis_host,
                                :port => redis_port,
                                :password => redis_password))
        Resque.redis = Redis.new( :host => redis_host,
                                :port => redis_port,
                                :password => redis_password)
      end
    end
    
    configure do
      ActionMailer::Base.delivery_method = :smtp
      email_settings = YAML::load(File.open("#{File.dirname(__FILE__)}/email.yml"))

      configure_redis
      
      if ENV['VCAP_SERVICES'].nil?
        WorkerMiner.set_main_url("http://localhost:3000")
        ActionMailer::Base.smtp_settings = email_settings["development_out"] unless email_settings["development_out"].nil?
      else
        WorkerMiner.set_main_url("http://your_app.cloudfoundry.com")
        ActionMailer::Base.smtp_settings = email_settings["production_out"] unless email_settings["production_out"].nil?
      end

      Resque::Worker.all.each { |w| w.unregister_worker }
      @@threads = []
      @@workers = []

      queues = "default;high".split(';')
      queues.each { |q| add_worker(*q.split(',')) }

      host = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['hostname'] rescue '127.0.0.1'
      port = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['port'] rescue 27017
      database = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['db'] rescue 'your_app_development'
      username = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['username'] rescue ''
      password = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['password'] rescue ''
      MongoMapper.connection = Mongo::Connection.new(host, port, :pool_size => 5, :timeout => 5)
      MongoMapper.database = database
      if username.blank?
        puts "Connected?"
      else
        MongoMapper.database.authenticate(username, password)
      end
    end


    get '/' do
      out= <<-OUT
      <html><head><title>Pages</title></head><body>
      Hi there
      </body></html>
      OUT
      out
    end



    get '/dev' do
      return {'database_count' => MongoMapper.connection.db("db").collection('profiles').find(:all).count }.to_json
    end

  end
end

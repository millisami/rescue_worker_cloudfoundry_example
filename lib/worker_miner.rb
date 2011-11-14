require 'oauth'
require 'yaml'
require 'json'
require 'nestful'

class WorkerMiner

  def self.set_redis(redis)
    @@redis = redis
  end

  def self.redis
    @@redis
  end 

  def self.set_main_url(url)
    @@main_url = url
  end

  def self.main_url
    @@main_url
  end

end

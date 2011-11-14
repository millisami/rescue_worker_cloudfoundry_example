require 'redis'

class JoinStuff
    @queue = :high

    def self.perform(params)
      join1 = params['join1']
      join2 = params['join1']
      db = WorkerMiner.redis
      db.select(4)
      
      db.sadd "#{join1}:friends", join2
    end

end

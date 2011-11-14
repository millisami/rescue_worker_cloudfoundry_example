require 'nestful'

class EmailSentCount
    @queue = :high

    def self.perform(params)
      puts "Stats....: #{WorkerMiner.main_url}"
      Nestful.put "#{WorkerMiner.main_url}/someendpointtocollectstats"
    end

end

class Research
    @queue = :high

    def self.perform(params)
      puts "Provided params: #{params.inspect}"
    end

end
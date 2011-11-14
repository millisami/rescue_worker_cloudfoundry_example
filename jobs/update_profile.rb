class UpdateProfile
    @queue = :high

    def self.perform(params)
      email = params['email'].strip
      full_name = params['full_name'].strip rescue ""
      puts "Provided params: #{params.inspect}"
      profile = Profile.find_by_email(email)
      puts "Found #{profile.full_name} with email : #{profile.email}"
      profile.some_field = "updated #{Time.now}"
      profile.save
    end

end
require 'nestful'

class EmailIt
    @queue = :high

    def self.perform(params)
      from_email = params['from_email'] || "xxxxxxxxx@gmail.com"
      user_name = params['user_name'] || "No Name Found"
      user_email = params['user_email'] || "unfound+xxxxxxx@gmail.com"
      subject = params['subject'] || "No subject"

      Mailer.the_email(from_email, user_name, user_email, subject).deliver
    end

end
require 'action_mailer'

class Mailer < ActionMailer::Base
  default :from => "xxxxx@gmail.com"

  def the_email(recipient, name, email, original_subject)
  	to = ["xxxxx@gmail.com"]
  	subject = "Weeeee?: #{name.blank? ? email : name}"
    @name = name
    @email = email
    @mail_subject = subject

    
    puts "Mailing..."

    mail(:to => to, :subject => subject) do |format|
      format.text { render "mailer/the_email" }
      format.html { render "mailer/the_email" }
    end
  end

end


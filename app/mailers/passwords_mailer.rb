class PasswordsMailer < ActionMailer::Base

  default :from => "mailer@friskyfactory.com"

  def reset(user, current_site)
    @user, @current_site = user, current_site
    email = Rails.env.production? ? @user.email : 'michael@michaelbamford.com'
    subject = "Reset #{current_site.display_name} Password"
    mail :to => email, :subject => subject
  end

end

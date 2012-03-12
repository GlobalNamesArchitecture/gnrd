class Mailer < ActionMailer::Base
  default from: "admin@globalnames.org"
  
  def error_email
    mail(:to => Namespotter::Application.config.default_admin_email, :subject => "Global Names GNRD error") do |format|
      format.text
    end
  end
  
end
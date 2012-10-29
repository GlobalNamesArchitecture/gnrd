source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-flash'
gem 'sinatra-redirect-with-flash'
gem 'sinatra-reloader'
gem 'mysql2'
gem "activerecord"
gem "haml"
gem "sass"
gem "name-spotter", "= 0.2.4"
gem "mechanize"
gem "docsplit"
gem "rspec"
gem "resque"
gem "rack"
gem "rack-timeout"
gem "rack-test"
gem "builder"
gem "actionpack"
gem "sanitize"
gem "mail"

group :development, :test do
  gem 'debugger'
  gem 'capybara'
  gem 'rdp-ruby-prof'
end

group :production do
  gem 'thin'
  gem 'rack-google-analytics'
end

group :test do
  # Pretty printed test output
  gem 'rake'
  gem 'turn', '0.8.2', :require => false
end

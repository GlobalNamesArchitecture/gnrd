source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-flash'
gem 'sinatra-reloader'
gem 'mysql2'
gem "activerecord", "~> 3.2.3"
gem "haml"
gem "sass"
gem "name-spotter", "= 0.2.0"
gem "mechanize"
gem "docsplit"
gem "rspec"
gem "resque"
gem "rack"
gem "rack-test"
gem "builder"

group :development, :test do
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'capybara'
end

group :production do
  gem 'thin'
  gem 'rack-google-analytics'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end

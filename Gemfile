source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-reloader'
gem 'mysql2'
gem "activerecord", "~> 3.2.3"
gem "haml"
gem "sass"
gem "name-spotter"
gem "mechanize"
gem "docsplit"
gem "rspec"
gem "resque"
gem "rack-flash"
gem "rack-test"
gem "builder"
gem "mailfactory"

group :development, :test do
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'capybara'
end

group :production do
  gem 'thin'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end

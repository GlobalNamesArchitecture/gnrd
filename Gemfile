source "https://rubygems.org"

gem "actionpack", "~> 4.2"
gem "activerecord", "~> 4.2"
gem "docsplit", "~> 0.7"
gem "ruby-filemagic", "~> 0.7" # libmagic-dev is dependency
gem "haml", "~> 4.0"
gem "iconv", "~> 1.0.4" # required by docsplit
gem "mail", "~> 2.6"
gem "mechanize", "~> 2.7"
gem "mysql2", "~> 0.4"
gem "name-spotter", "~> 0.3"
gem "rack", "~> 1.6"
gem "rack-test", "~> 0.6"
gem "rack-timeout", "~> 0.3.2"
gem "resque", "~> 1.25"
gem "rest-client", "~> 1.8"
gem "sanitize", "~> 4.0"
gem "sass", "~> 3.4"
gem "sinatra", "~> 1.4"
gem "sinatra-activerecord", "~> 2.0"
gem "sinatra-flash", "~> 0.3"
gem "sinatra-redirect-with-flash", "~> 0.2"
gem "sinatra-reloader", "~> 1.0"

group :development do
  gem "byebug", "~> 1.8"
end

group :production do
  gem "unicorn", "~> 5.0"
  gem "rack-google-analytics", "~> 1.2"
end

group :test do
  gem "capybara", "~> 2.6"
  gem "coveralls", "~> 0.8", require: false
  gem "rake", "~> 10.5"
  gem "rspec", "~> 3.4"
  gem "rubocop", "~> 0.37"
  gem "turn", "0.9", require: false
end

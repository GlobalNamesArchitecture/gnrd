# frozen_string_literal: true

source "https://rubygems.org"

gem "actionpack", "~> 5.2"
gem "activerecord", "~> 5.2"
gem "addressable", "~> 2.5"
gem "docsplit", "~> 0.7"
gem "gnfinder", "~> 0.2"
gem "grpc", "~> 1.15"
gem "grpc-tools", "~> 1.15"
gem "haml", "~> 5.0"
gem "iconv", "~> 1.0.5" # required by docsplit
gem "mail", "~> 2.7"
gem "name-spotter", "~> 0.3.3"
gem "pg", "~> 1.1" # libpq-dev is dependency
gem "puma", "~> 3.12"
gem "rack", "~> 2.0"
gem "rack-test", "~> 1.1"
gem "rack-timeout", "~> 0.5"
gem "rchardet", "~> 1.8"
gem "resque", "~> 1.27", require: "resque/server"
gem "rest-client", "~> 2.0"
gem "ruby-filemagic", "~> 0.7" # libmagic-dev is dependency
gem "sanitize", "~> 4.6"
gem "sass", "~> 3.6"
gem "sinatra", "~> 2.0"
gem "sinatra-activerecord", "~> 2.0"
gem "sinatra-flash", "~> 0.3"
gem "sinatra-redirect-with-flash", "~> 0.2"
gem "sinatra-reloader", "~> 1.0"

group :development do
  gem "bundler", "~> 2.0"
  gem "byebug", "~> 10.0"
  gem "git", "~> 1.5"
  gem "shotgun", "~> 0.9"
end

group :production do
  gem "rack-google-analytics", "~> 1.2"
end

group :test do
  gem "capybara", "~> 3.8"
  gem "coveralls", "~> 0.8", require: false
  gem "factory_bot", "~> 4.11"
  gem "rake", "~> 12.3"
  gem "rspec", "~> 3.8"
  gem "rubocop", "~> 0.59"
end

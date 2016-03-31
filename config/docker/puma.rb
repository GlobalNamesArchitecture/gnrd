threads 1, 6
workers 8

app_dir = File.expand_path("../../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"

# Default to production
rack_env = ENV["RACK_ENV"] || "production"
environment rack_env

# Set up socket location
bind "unix://#{tmp_dir}/puma.sock"

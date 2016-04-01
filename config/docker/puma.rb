threads 1, 6
workers ENV["PUMA_WORKERS"] || 4

app_dir = File.expand_path("../../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"

# Default to production
rack_env = ENV["RACK_ENV"] || "production"
environment rack_env

# Set up socket location
bind "unix://#{tmp_dir}/puma.sock"

# Logging
stdout_redirect("#{app_dir}/log/puma.stdout.log",
                "#{app_dir}/log/puma.stderr.log", true)

# Set master PID and state locations
pidfile "#{tmp_dir}/puma.pid"
state_path "#{tmp_dir}/puma.state"
activate_control_app

on_worker_boot do
  require_relative "../../environment"
end

# Change to match your CPU core count
workers ENV["CPU_NUM"] || 2

# Min and Max threads per worker
threads 1, 6

app_dir = "/app"
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ["RACK_ENV"] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{app_dir}/log/puma.stdout.log",
  "#{app_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app "tcp://0.0.0.0:9293"
rackup "#{app_dir}/config.ru"

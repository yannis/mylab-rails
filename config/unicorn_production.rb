# Set environment to development unless something else is specified
env = "production"
wd = "/var/www/mylab_rails_production/current/"
working_directory wd
pid "#{wd}tmp/pids/mylab_rails_production_unicorn.pid"
stderr_path "#{wd}log/mylab_rails_production_unicorn.stderr.log"
stdout_path "#{wd}log/mylab_rails_production_unicorn.stdout.log"

listen "#{wd}tmp/sockets/mylab_rails_production_unicorn.sock"
worker_processes 3
timeout 30

# Edit the unicorn.rb to your desire ,it's well commented and please remember to change the port to 8081! NGINX will run on port 8080 with the above nginx.conf, so unicorn cun't run on the same port. The line you have to change for the port should look like this:
# listen 8080, tcp_nopush: true
listen 8088, tcp_nopush: true

# Preload our app for more speed
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  # old_pid = "/tmp/pids/mylab_rails_production_unicorn.pid.oldbin"
  # if File.exists?(old_pid) && server.pid != old_pid
  #   begin
  #     Process.kill("QUIT", File.read(old_pid).to_i)
  #   rescue Errno::ENOENT, Errno::ESRCH
  #     # someone else did our job for us
  #   end
  # end


  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

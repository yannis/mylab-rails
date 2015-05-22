# Example: now to run unicorn, and monitor its child processes

RUBY = '/Users/yannis/.rbenv/shims/ruby' # ruby on the server
APP_PATH = '/var/www/mylab_rails_production/current'
RAILS_ENV = 'production'

Eye.config do
  logger "#{APP_PATH}/log/eye.log"
end

Eye.application "mylab_rails_production" do
  env "RAILS_ENV" => RAILS_ENV

  # unicorn requires to be `ruby` in path (for soft restart)
  env "PATH" => "#{File.dirname(RUBY)}:#{ENV['PATH']}"

  # env 'RBENV_ROOT' => '/usr/local/rbenv', 'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:#{ENV['PATH']}"

  working_dir "/var/www/mylab_rails_production/current"

  process("unicorn") do
    uid "yannis"
    pid_file "tmp/pids/mylab_rails_production_unicorn.pid"
    # start_command "#{RUBY} ./bin/unicorn -Dc ./config/unicorn.rb -E #{RAILS_ENV}"
    start_command "bundle exec unicorn -c config/unicorn_production.rb -E production -D"
    start_grace 10
    stdall "log/unicorn.log"

    # stop signals:
    # http://unicorn.bogomips.org/SIGNALS.html
    stop_signals [:TERM, 10.seconds]

    # soft restart
    restart_command "kill -USR2 {PID}"

    check :cpu, :every => 30, :below => 80, :times => 3
    check :memory, :every => 30, :below => 250.megabytes, :times => [3,5]

    start_timeout 100.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command "kill -QUIT {PID}"
      check :cpu, :every => 30, :below => 80, :times => 3
      check :memory, :every => 30, :below => 250.megabytes, :times => [3,5]
    end
  end
end

APPLICATION_NAME = 'mylab_rails_production'
RUBY = '/Users/yannis/.rbenv/shims' # ruby on the server
APP_PATH = File.expand_path("..", File.dirname(__FILE__))
RAILS_ENV = 'production'
RBENV_VERSION = File.read("#{APP_PATH}/.rbenv-version").strip

Eye.config do
  logger "#{APP_PATH}/log/eye.log"
end


Eye.application :mylab_rails_production_sidekiq do
  memory_rails_instance_check_options = { every: 1.minute, below: 250.megabytes, times: [3, 5] }
  cpu_rails_instance_check_options = { every: 30.seconds, below: 80, times: [3, 5] }

  working_dir APP_PATH

  env "RAILS_ENV" => RAILS_ENV
  env "RBENV_ROOT" => "/Users/yannis/.rbenv"
  env "RBENV_VERSION" => RBENV_VERSION
  env "PATH" => "/Users/yannis/.rbenv/versions/#{RBENV_VERSION}/bin:#{ENV['PATH']}"
  env "BUNDLE_GEMFILE" => "#{APP_PATH}/Gemfile"

  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 30.seconds, below: 100, times: 3

  process :sidekiq do
    memory_rails_instance_check_options = { every: 1.minute, below: 250.megabytes, times: [3, 5] }
    cpu_rails_instance_check_options = { every: 30.seconds, below: 80, times: [3, 5] }
    pid_file "tmp/pids/sidekiq.pid"

    start_command "/Users/yannis/.rbenv/shims/bundle exec sidekiq -d -e #{RAILS_ENV} -L log/sidekiq.log -C config/sidekiq.yml"
    # Tell sidekiq to finish his current jobs and stop taking next jobs,
    # wait a little and then tell sidekiq to kill his running jobs.
    stop_signals [:USR1, 30.seconds, :TERM]
    # Sidekiq will wait {sidekiq.yml#timeout} seconds after getting TERM signal with killing itself.
    # Let's wait a bit more than that.
    stop_grace 15.seconds

    start_timeout 30.seconds
    start_grace 30.seconds

    stdall "log/eye.sidekiq.log"

    check :memory, memory_rails_instance_check_options

    monitor_children do
      check :cpu, cpu_rails_instance_check_options
      check :memory, memory_rails_instance_check_options
      stop_command "kill -QUIT {PID}"
    end
  end
end

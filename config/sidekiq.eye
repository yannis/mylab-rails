# Example: how to run sidekiq daemon

RUBY = '/Users/yannis/.rbenv/shims/ruby' # ruby on the server
APP_PATH = '/var/www/mylab_rails_production/current'
RAILS_ENV = 'production'

Eye.config do
  logger "#{APP_PATH}/log/eye.log"
end

def sidekiq_process(proxy, name)
  proxy.process(name) do
    start_command "bundle exec sidekiq -e #{RAILS_ENV} -C config/sidekiq.yml"
    pid_file "tmp/pids/#{name}.pid"
    stdall "log/#{name}.log"
    daemonize true
    stop_signals [:USR1, 0, :TERM, 10.seconds, :KILL]

    check :cpu, :every => 30, :below => 100, :times => 5
    check :memory, :every => 30, :below => 300.megabytes, :times => 5
  end
end

Eye.application :sidekiq_test do
  working_dir APP_PATH

  sidekiq_process self, :sidekiq
end

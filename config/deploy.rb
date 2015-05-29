# config valid only for current version of Capistrano
lock '3.4.0'

set :repo_url, 'git@github.com:yannis/mylab-rails.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml}
# set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :rbenv_path, "/Users/yannis/.rbenv"
# set :default_environment,           {
#   "PATH" => "/usr/local/bin:/usr/local/sbin:/Users/yannis/.rbenv/shims:/Users/yannis/.rbenv/bin:$PATH"
# }

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.2.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} /usr/local/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

# Default value for keep_releases is 5
set :keep_releases, 5
server '129.194.56.70', user: 'yannis', roles: %w{web app db}

task :staging do
  set :branch, "bootstrap"
  set :stage, 'staging'
end


task :production do
  set :branch, "master"
  set :stage, 'production'
end

set :rails_env, fetch(:stage)
set :application, "mylab_rails_#{fetch(:stage)}"
set :deploy_to, "/var/www/#{fetch(:application)}"
set :eye_unicorn_config, "#{fetch(:deploy_to)}/current/config/unicorn_#{fetch(:stage)}.eye"
# set :god_unicorn_config, "#{fetch(:deploy_to)}/current/config/unicorn_#{fetch(:stage)}.god"
# set :god_with_path, "/Users/yannis/.rbenv/shims/god"

namespace :deploy do

  task :start do
    on roles(:app) do
      execute "/usr/local/bin/eye start #{fetch(:application)}"
    end
  end

  task :stop do
    on roles(:app) do
      execute "/usr/local/bin/eye stop #{fetch(:application)}"
    end
  end

  task :restart do
    on roles(:app) do
      execute "/usr/local/bin/eye restart #{fetch(:application)}"
    end
  end

  desc "Start or reload eye config"
  task :load_eye do
    # run "mkdir -p /home/deploy/projects/eye"
    # run "ln -sf #{current_path}/deployment/eye.#{rails_env}.rb /home/deploy/projects/eye/#{fetch(:application)}.eye"
    # run "eye load /home/deploy/projects/eye/#{fetch(:application)}.eye"
    on roles(:app) do
      execute "/usr/local/bin/eye l #{fetch(:eye_unicorn_config)}"
    end
  end

  task :add_log do
    on roles(:app) do
      within repo_path do
        execute :git, :log, "--date=local", "--pretty=format:'%ad: %s (%an)'", "--no-merges #{fetch(:branch)}", ">", "#{fetch(:deploy_to)}/current/public/log.txt"
      end
    end
  end
end

before "deploy:restart", "deploy:load_eye"
after "deploy:cleanup", "deploy:restart"
# after "deploy:restart", "airbrake:deploy"
# after "airbrake:deploy", "deploy:add_log"

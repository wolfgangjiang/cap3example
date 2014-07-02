# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'cap3example'
set :repo_url, 'https://github.com/wolfgangjiang/cap3example.git'
set :use_sudo, false
set :deploy_timestamped, true
set :release_name, Time.now.localtime.strftime("%Y%m%d%H%M%S")
set :keep_releases, 5
set :rvm_ruby_version, "2.0.0"

set :linked_files, %w{.ruby-version .ruby-gemset config/mongoid.yml config/unicorn.rb config/secrets.yml}

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets public/system}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :start do
    on roles(:app) do
      within release_path do
        set :rvm_path, "~/.rvm"
        execute :bundle, "exec", "unicorn_rails", "-c", File.join(release_path, "config/unicorn.rb"), "-E production", "-D"
      end
    end
  end

  task :stop do
    on roles(:app) do
      pid_file = File.join(release_path, "tmp/pids/unicorn.pid")
      execute "if [[ -e #{pid_file} ]]; then kill $(cat #{pid_file}); fi"
    end
  end

  task :restart do
    invoke "deploy:stop"
    invoke "deploy:start"
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

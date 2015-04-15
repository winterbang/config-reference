SSHKit.config.command_map[:rails] = "bundle exec rails"
SSHKit.config.command_map[:rake] = "bundle exec rake"

lock '3.2.1'

set :application, 'AppName'
set :pty, true
set :deploy_via, :remote_cache
# set :use_sudo, false

set :stages, ["production"]

set :scm, :git
set :repo_url, 'git@git.github.com:winterbang/AppName.git'

# rvm
set :rvm_type, :user
set :rvm_ruby_version, '2.1.3'
set :default_env, { rvm_bin_path: '~/.rvm/bin' }

set :linked_files, %w{config/database.yml config/config.yml config/initializers/carrierwave.rb config/initializers/redis.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets}

set :ssh_options, {
  user: 'winter',
  keys: [File.expand_path('~/.ssh/id_rsa')],
  forward_agent: false,
  auth_methods: %w(publickey)
}

set :keep_releases, 12

set :whenever_identifier, ->{ "#{fetch(:application)}_production}" }
namespace :deploy do
  desc 'Setup application'
  task :setup do
    invoke 'nginx:setup'
  end

  desc 'Restart application'
  # task :restart do
  #   invoke 'puma:restart'
  #   invoke 'deploy:update_crontab'
  # end
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
    end
  end

  desc "update crotab with whenever"
  task :update_crontab do
    on roles(:all) do
      within release_path do
        execute :bundle, :exec, "whenever --update-crontab #{fetch(:whenever_identifier)} "
      end
    end
  end

  task :rake do
    on roles(:all), in: :sequence, wait: 5 do
      within release_path do
        execute :rake, ENV['task'], "RAILS_ENV=production"
      end
    end
    # cap staging deploy:rake task=add_headimg:seed
  end

  after :restart, :'puma:restart'
  after :restart, :'deploy:update_crontab'
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  after :publishing, :restart
  after :finishing, 'deploy:cleanup'
end

# HipChat
set :hipchat_token, "7f0a83d0a0d9579bed97bb712b664"
set :hipchat_room_name, "kz"
set :hipchat_announce, false
set :hipchat_color, 'yellow'
set :hipchat_success_color, 'green'
set :hipchat_failed_color, 'red'
set :hipchat_message_format, 'html'
set :hipchat_options, {
  :api_version  => "v2"
}

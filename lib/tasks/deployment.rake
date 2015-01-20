# Deploy and rollback on Heroku in staging and production
task :deploy_staging    => ['deploy:set_staging_app',
                            'deploy:push',
                            'deploy:migrate',
                            'deploy:post_deploy',
                            'deploy:restart']
task :deploy_production => ['deploy:set_production_app',
                            'deploy:push',
                            'deploy:migrate',
                            'deploy:post_deploy',
                            'deploy:restart']

task :post_deploy_staging    => ['deploy:set_staging_app',
                                 'deploy:post_deploy',
                                 'deploy:restart']

task :post_deploy_production => ['deploy:set_production_app',
                                 'deploy:post_deploy',
                                 'deploy:restart']

namespace :deploy do
  PRODUCTION_APP = 'imua'
  STAGING_APP = 'imuastaging'

  task :set_staging_app do
    APP = STAGING_APP
    BRANCH = 'master'
  end

  task :set_production_app do
  	APP = PRODUCTION_APP
    BRANCH = 'master_prod'
  end

  task :push do
    puts "Let's check your tests!"
    puts `rake db:migrate RAILS_ENV=test`
    puts 'rake db:test:prepare RAILS_ENV=test'

    if system 'bundle exec rspec --fail-fast'
      puts "Deploying #{BRANCH} to #{APP}..."
      puts `git push -f git@heroku.#{APP}:#{APP}.git #{BRANCH}:master`
    else
      puts "FIX YOUR TESTS"
      fail
    end
  end

  task :restart do
    puts 'Restarting app servers...'
    run_clean "heroku restart --app #{APP}"
  end

  task :migrate do
    puts 'Running database migrations...'
    run_clean "heroku run rake db:migrate --app #{APP}"
  end

  task :off do
    puts 'Putting the app into maintenance mode...'
    run_clean "heroku maintenance:on --app #{APP}"
  end

  task :on do
    puts 'Taking the app out of maintenance mode...'
    run_clean "heroku maintenance:off --app #{APP}"
  end

  task :post_deploy do
    # NOTE: Tasks to be run when the app is deployed to production should be
    # put here
    puts 'Running post deploy tasks...'
    puts '############################'

    run_clean "heroku run rake db_update:post_deploy --app #{APP}"

    puts '############################'
    puts 'Post deploy tasks complete.'
  end

  def run_clean command
    Bundler.with_clean_env {
      puts `#{command}`
    }
  end
end

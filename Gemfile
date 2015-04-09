source 'https://rubygems.org'
ruby "2.1.2"
gem 'rails', '3.2.19'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'thin'
gem 'unicorn'
gem "rack-timeout"

# Setting this to 1.0.3 to see if this affected the
# memory leak. This commit: https://github.com/neelbhat88/imuadev/pull/780/files
# updated eventmachine when upgrading to ruby 2.1.5. Downgrading in the next
# commit did not change eventmachine so setting this manually here
# This is more of a shot in the dark. We can remove this if it doens't work
gem 'eventmachine', '1.0.3'

group :development do
  #gem 'debugger'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'factory_girl_rails', "~> 4.0"
  gem 'jasmine'
end

group :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails' ,"~> 4.0"
  gem 'jasmine'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem "font-awesome-rails"

gem 'jquery-rails'
# gem 'jquery-ui-rails'
gem 'jquery-placeholder-rails'

gem 'bootstrap-sass', '~>3.1.1'

gem 'newrelic_rpm'

gem 'angular-rails-templates'
gem 'angular-ui-bootstrap-rails'
gem 'angularjs-rails', "~> 1.3.0"
gem 'angular_rails_csrf', :git=>'https://github.com/jsanders/angular_rails_csrf.git'

gem 'mail'

gem 'acts_as_commentable', '3.0.1'

# Images
gem 'rmagick', '2.13.4'
gem 'paperclip'
gem 'aws-sdk'

# Used for authentication
gem 'devise', "~> 3.2.2"
# Authorization
gem "six"

gem "ladda-rails", :git => "git://github.com/Promptus/ladda-rails.git"

gem "d3-rails"

# Analytics
gem 'intercom-rails'
gem 'intercom', "~> 2.2.1" #Intercom API
gem 'keen'

# Optimizations
gem 'oj'
gem 'valium'

# Security checks
gem "brakeman", :require => false

# Less verbose logging
gem "lograge"
gem 'quiet_assets'

# CORS suppport
gem 'rack-cors', :require => 'rack/cors'

# Tracking memory issues
gem 'oink'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

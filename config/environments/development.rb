Imua::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Default mailer for Devise
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: ENV['ROOT_URL'] }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              'smtp.sendgrid.net',
    port:                 587,
    domain:               'myimua.org',
    user_name:            ENV['SENDGRID_USERNAME'],
    password:             ENV['SENDGRID_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true  }

  # Paperclip
  config.paperclip_defaults = {
    :default_url => "https://imuaproduction.s3.amazonaws.com/images/default-avatar.png",
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['AWS_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.assets.compress = false
  config.assets.compile = true
  config.assets.digest = false
  config.assets.debug = false

  # Tell Unicorn to log just like WEBbrick and Thin web servers do
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger.const_get('DEBUG')

  # Enable lograge logging
  config.lograge.enabled = true

end

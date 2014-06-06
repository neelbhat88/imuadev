# config/initializers/timeout.rb
# https://devcenter.heroku.com/articles/rails-unicorn
# When any request takes longer than this timeout, the request is closed and a stacktrace is
# generated in the logs.
Rack::Timeout.timeout = 10  # seconds
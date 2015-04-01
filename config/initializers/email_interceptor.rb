ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
ActionMailer::Base.register_interceptor(ProductionMailInterceptor) if Rails.env.production?

Rails.application.middleware.use( Oink::Middleware, :logger => Hodel3000CompliantLogger.new(STDOUT) )

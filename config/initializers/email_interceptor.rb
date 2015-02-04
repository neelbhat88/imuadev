ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
ActionMailer::Base.register_interceptor(ProductionMailInterceptor) if Rails.env.production?

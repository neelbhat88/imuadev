class IntercomProvider < AnalyticsEventProvider

  def initialize
    super

    Intercom.app_id = ENV["INTERCOM_APP_ID"]
    Intercom.app_api_key = ENV["INTERCOM_API_KEY"]
  end

  def create_event(event_name, user_id, metadata=nil)
    Background.process do
      Intercom::Event.create(
        :event_name => event_name,
        :created_at => Time.now.to_i,
        :user_id => user_id,
        :metadata => metadata
      )
    end
  end

end

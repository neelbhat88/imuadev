class ServiceDateToDateTime < ActiveRecord::Migration
  change_column(:user_service_activity_events, :date, :datetime)
end

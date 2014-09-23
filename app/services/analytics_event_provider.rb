class AnalyticsEventProvider

  def initialize

  end

  def self.events
    {
      updated_expectation: "updated-expectation",
      created_task: "created-task",
      completed_task: "completed-task",
      updated_data: "updated-data"
    }
  end

end

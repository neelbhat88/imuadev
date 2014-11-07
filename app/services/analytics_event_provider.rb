class AnalyticsEventProvider

  def initialize

  end

  def self.events
    {
      updated_expectation: "updated-expectation",
      updated_expectation_bulk: "updated-expectation-bulk",
      updated_expectation_other: "updated-expectation-other",
      created_task: "created-task",
      completed_task: "completed-task",
      updated_data: "updated-data"
    }
  end

end

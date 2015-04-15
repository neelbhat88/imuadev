class TakeTestMilestone < ImuaMilestone
  attr_accessor :target_org_test_title

  def initialize(milestone=nil)
    super

    @module = Constants.Modules[:TESTING]
    @submodule = Constants.SubModules[:TESTING_TAKE]

    @title = "Rock the Exam"
    @description = "Take the following exam:"
    @icon = "https://imuaproduction.s3.amazonaws.com/images/Testing.jpg"

    @milestone_description = "A milestone to set a requirement to take a specific Test set up in your Organization Setup. This milestone is automatically triggered when a user completes the test. This does not check the score of the test (only completion)."

    if milestone.nil?
      @target_org_test_title = @value
    else
      @target_org_test_title = milestone.value
    end
  end

  def has_earned?(user, time_unit_id)
    test_taken = false
    org_test_id = -1

    testService = TestService.new

    # Find the org_test_id for the target_org_test_title
    org_tests = testService.get_org_tests(user.organization_id)
    org_tests.each do | ot |
      if ot.title == target_org_test_title
        org_test_id = ot.id
        break
      end
    end

    # See if there are any user_tests for the org_test_id
    if org_test_id != -1
      user_tests = testService.get_user_tests_time_unit(user.id, time_unit_id)
      user_tests.each do | ut |
        if ut.org_test_id === org_test_id
          test_taken = true
          break
        end
      end
    end

    @earned = test_taken
  end

  def valid?

    if super
      org_tests = TestService.new.get_org_tests(organization_id)
      org_tests.each do | ot |
        if ot.title === @value
          return true
        end
      end
    end

    return false
  end

end

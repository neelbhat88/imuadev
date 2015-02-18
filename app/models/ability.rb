class Ability
  # Static methods
  class << self

    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "User" then user_abilities(user, subject)
      when "Organization" then organization_abilities(user, subject)
      when "Assignment" then assignment_abilities(user, subject)
      when "UserAssignment" then user_assignment_abilities(user, subject)
      when "Expectation" then expectation_abilities(user, subject)
      when "Comment" then comment_abilities(user, subject)
      else []
      end

    end

    def user_abilities(user, subjectUser)
      rules = []

      if user.super_admin?
        return [
          :delete_user,
          :edit_user_info,
          :view_profile,
          :change_semester,
          :read_user_tests,
          :manage_user_tests,
          :manage_user_extracurricular_and_service,
          :read_parent_guardian_contacts,
          :manage_parent_guardian_contacts,
          :get_student_expectations,
          :get_student_dashboard,
          :get_user_progress,
          :get_user_assignments,
          :create_user_assignment,
          :get_user_assignment_collections,
          :get_assignments,
          :create_assignment,
          :create_assignment_broadcast,
          :get_task_assignable_users,
          :get_task_assignable_users_tasks
        ]
      else
        return [] if user.organization_id != subjectUser.organization_id
      end

      # Actions on himself
      if user.id == subjectUser.id
        rules += [
          :update_password,
          :view_profile,
          :edit_user_info,
          :read_user_tests,
          :manage_user_tests,
          :manage_user_extracurricular_and_service,
          :read_parent_guardian_contacts,
          :manage_parent_guardian_contacts,
          :get_student_expectations,
          :get_student_dashboard,
          :get_user_progress,
          :get_user_assignments,
          :create_user_assignment,
          :get_user_assignment_collections,
          :get_assignments,
          :create_assignment,
          :create_assignment_broadcast,
          :get_task_assignable_users,
          :get_task_assignable_users_tasks
        ]

      elsif user.org_admin?
        rules += [
          :delete_user,
          :edit_user_info,
          :view_profile,
          :change_semester,
          :read_user_tests,
          :manage_user_tests,
          :manage_user_extracurricular_and_service,
          :read_parent_guardian_contacts,
          :manage_parent_guardian_contacts,
          :get_student_expectations,
          :get_student_dashboard,
          :get_user_progress,
          :get_user_assignments,
          :create_user_assignment,
          :get_user_assignment_collections,
          :get_assignments,
          :get_task_assignable_users,
          :get_task_assignable_users_tasks
        ]

      elsif user.mentor?
        if subjectUser.student?
          related = UserRepository.new.are_related?(subjectUser.id, user.id)
          if related
            rules += [
              :view_profile,
              :change_semester,
              :edit_user_info,
              :read_user_tests,
              :manage_user_tests,
              :manage_user_extracurricular_and_service,
              :read_parent_guardian_contacts,
              :manage_parent_guardian_contacts,
              :get_student_expectations,
              :get_student_dashboard,
              :get_user_progress,
              :get_user_assignments,
              :create_user_assignment,
              :get_user_assignment_collections,
              :get_assignments,
              :get_task_assignable_users,
              :get_task_assignable_users_tasks
            ]
          else # students not assigned to this mentor (read-only)
            rules += [
              :view_profile,
              :read_user_tests,
              :read_parent_guardian_contacts,
              :get_student_expectations,
              :get_student_dashboard,
              :get_user_progress,
              :get_user_assignments,
              :get_user_assignment_collections,
              :get_assignments,
              :get_task_assignable_users,
              :get_task_assignable_users_tasks
            ]
          end
        else # other users in their organization (other mentors, admins)
          rules += [
            :view_profile
          ]
        end

      elsif user.student?
        related = UserRepository.new.are_related?(user.id, subjectUser.id)
        if related
          rules += [
            :view_profile
          ]
        end

      end

      rules.uniq
    end

    def organization_abilities(user, subjectOrg)
      rules = []

      if user.super_admin?
        return [:create_user,
                :read_org_tests,
                :manage_org_tests,
                :get_organization_progress,
                :reset_passwords]
      else
        return [] if user.organization_id != subjectOrg.id
      end

      if user.org_admin?
        rules += [:create_user,
                  :read_org_tests,
                  :manage_org_tests,
                  :get_organization_progress,
                  :reset_passwords]
      end

      if user.mentor?
        rules += [:read_org_tests]
      end

      if user.student?
        rules += [:read_org_tests]
      end

      rules.uniq
    end

    def assignment_abilities(user, subjectAssignment)
      rules = []

      if user.super_admin?
        return[:get_assignment,
               :update_assignment,
               :destroy_assignment,
               :get_assignment_collection,
               :update_assignment_broadcast]
      else
        return [] if user.organization_id != subjectAssignment.organization_id
      end

      if user.org_admin?
        rules += [:get_assignment,
                  :update_assignment,
                  :destroy_assignment,
                  :get_assignment_collection,
                  :update_assignment_broadcast]
      end

      if user.mentor?
        rules += [:get_assignment,
                  :get_assignment_collection]
      end


      if subjectAssignment.assignment_owner_type == "User" &&
         user.id == subjectAssignment.assignment_owner_id
        rules += [:get_assignment,
                  :update_assignment,
                  :destroy_assignment,
                  :get_assignment_collection,
                  :update_assignment_broadcast]
      end

      rules.uniq
    end

    def user_assignment_abilities(user, subjectUserAssignment)
      rules = []
      subjectUser = nil

      if user.super_admin?
        return[:update_user_assignment,
               :destroy_user_assignment,
               :get_user_assignment_collection,
               :index_comments,
               :create_comment]
      else
        subjectUser = User.where(id: subjectUserAssignment.user_id).first
        return [] if user.organization_id != subjectUser.organization_id
      end

      if user.org_admin?
        rules += [:update_user_assignment,
                  :destroy_user_assignment,
                  :get_user_assignment_collection,
                  :index_comments,
                  :create_comment]
      end

      if user.mentor?
        related = UserRepository.new.are_related?(subjectUser.id, user.id)
        if related
          rules += [:update_user_assignment,
                    :destroy_user_assignment,
                    :get_user_assignment_collection,
                    :index_comments,
                    :create_comment]
        elsif subjectUser.student?
          rules += [:get_user_assignment_collection]
        end
      end

      if user.id == subjectUser.id
        rules += [:update_user_assignment,
                  :get_user_assignment_collection,
                  :index_comments,
                  :create_comment]
      end

      rules.uniq
    end

    def expectation_abilities(user, subjectExpectation)
      rules = []
      subjectOrg = nil

      if user.super_admin?
        return [:get_expectation_status,
                :put_expectation_status]
      else
        subjectOrg = Organization.where(id: subjectExpectation.organization_id).first
        return [] if user.organization_id != subjectOrg.id
      end

      if user.org_admin?
        rules += [:get_expectation_status,
                  :put_expectation_status]
      end

      if user.mentor?
        rules += [:get_expectation_status,
                  :put_expectation_status]
      end

      rules.uniq
    end

    def comment_abilities(user, subjectComment)
      rules = []
      subjectUser = nil

      if user.super_admin?
        return [:update_comment,
                :destroy_comment]
      else
        subjectUser = User.where(id: subjectComment.user_id).first
        return [] if user.organization_id != subjectUser.organization_id
      end

      if user.id == subjectUser.id
        rules += [:update_comment,
                  :destroy_comment]
      end

      rules.uniq
    end

  end

end

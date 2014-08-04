class Ability
  # Static methods
  class << self

    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "User" then user_abilities(user, subject)
      when "Organization" then organization_abilities(user, subject)
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
        ]
      else
        return [] if user.organization_id != subjectUser.organization_id
      end

      # Actions on himself
      if user.id == subjectUser.id
        rules += [
          :update_password,
          :view_profile,
          :edit_user_info
        ]

      elsif user.org_admin?
        rules += [
          :delete_user,
          :edit_user_info,
          :view_profile,
          :change_semester
        ]

      elsif user.mentor?
        if subjectUser.student?
          related = UserRepository.new.are_related?(subjectUser.id, user.id)
          if related
            rules += [
              :view_profile,
              :change_semester,
              :edit_user_info
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
            :view_profile,
          ]
        end

      end

      rules.uniq
    end

    def organization_abilities(user, subjectOrg)
      rules = []

      if user.super_admin?
        return [:create_user]
      else
        return [] if user.organization_id != subjectOrg.id
      end

      if user.org_admin?
        rules += [:create_user]
      end

      rules.uniq
    end
  end

end

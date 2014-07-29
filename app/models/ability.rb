class Ability
  # Static methods
  class << self

    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "User" then user_abilities(user, subject)
      else []
      end

    end

    def user_abilities(user, subject)
      rules = []

      return [] if user.organization_id != subject.organization_id

      # Actions on himself
      if user.id == subject.id
        rules += [
          :update_password,
          :view_profile,
          :edit_user_info
        ]

      elsif user.org_admin?
        rules += [
          :create_user,
          :delete_user,
          :edit_user_info,
          :view_profile,
          :change_semester
        ]

      elsif user.mentor?
        if subject.student?
          related = UserRepository.new.are_related?(subject.id, user.id)
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
        related = UserRepository.new.are_related?(user.id, subject.id)
        if related
          rules += [
            :view_profile,
          ]
        end

      elsif user.super_admin?
        rules += [
          :create_user,
          :delete_user,
          :edit_user_info,
          :view_profile,
          :change_semester,
        ]
      end

      rules.uniq
    end
  end

end

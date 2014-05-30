class Constants
  def self.UserRole
    return {
      SUPER_ADMIN: 0,
      ORG_ADMIN: 10,
      SCHOOL_ADMIN: 20,
      COHORT_LEAD: 30,
      MENTOR: 40,
      STUDENT: 50,
      PARENT: 60
    }
  end

  def self.Modules
    return {
      ACADEMICS: "Academics",
      SERVICE: "Service"
    }
  end

  def self.SubModules
    return {
      ACADEMICS_GPA: "Academics_GPA",
      ACADEMICS_COURSES: "Academics_Courses",

      SERVICE_DEPTH_HOURS: "Service_DepthHours",
    }
  end
end

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
      SERVICE: "Service",
      EXTRACURRICULAR: "Extracurricular",
      COLLEGE_PREP: "College_Prep",
      TESTING: "Testing"
    }
  end

  def self.SubModules
    return {
      ACADEMICS_GPA:       "Academics_GPA",
      ACADEMICS_COURSES:   "Academics_Courses",

      SERVICE_DEPTH_HOURS: "Service_DepthHours",
      EXTRACURRICULAR_ACTIVITIES: "Extracurricular_Activities",

      YES_NO:              "YesNo",
    }
  end

  def self.TestScoreTypes
    return {
      PERCENT:      "Percent",
      RAW_NUMBER:   "Raw Number",
      LETTER_GRADE: "Letter Grade"
    }
  end

end

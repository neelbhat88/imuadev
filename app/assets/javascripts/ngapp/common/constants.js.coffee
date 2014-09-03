angular.module('myApp')
.constant 'CONSTANTS',

  'USER_ROLES':
    super_admin: 0
    org_admin: 10
    school_admin: 20
    cohort_lead: 30
    mentor: 40
    student: 50
    parent: 60

  'MODULES':
    academics: "Academics"
    service: "Service"
    testing: "Testing"
    extracurriculars: "Extracurricular"
    college_prep: "College_Prep"

  'CLASS_LEVELS':
    ap: "AP"
    honors: "Honors"
    regular: "Regular"

  'CLASS_SUBJECTS':
    english: "English"
    social_science: "Social Science"
    lab_science: "Laboratory Science"
    social_studies: "Social Studies"
    math_core: "Math - Core"
    math_other: "Math - Other"
    foreign_language: "Foreign Language"
    elective: "Elective"
    other: "Other"

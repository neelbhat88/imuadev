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
    pdu: "PDU"

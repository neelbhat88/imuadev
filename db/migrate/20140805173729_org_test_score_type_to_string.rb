class OrgTestScoreTypeToString < ActiveRecord::Migration
  change_column(:org_tests, :score_type, :string)
end

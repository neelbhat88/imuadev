############################################
########### THIS HAS BEEN DELETED ##########
############################################
#ToDo: Actually remove this table from the DB
# 5/27 - waiting to make sure we don't need this before removing
class MilestoneLevel < ActiveRecord::Base
  attr_accessible :milestone_id, :value, :title

  belongs_to :milestone
end
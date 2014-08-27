desc "Sets all credit_hours = 1 and level = 'Regular' for all User Classes where those values
      are nil"
task :update_all_user_classes => :environment do
  UserClass.where(:credit_hours => nil).update_all(:credit_hours => 1)
  UserClass.where(:level => nil).update_all(:level => "Regular")
end

require 'paratrooper'

# Deployment tasks: see http://hashrocket.com/blog/posts/when-pushing-just-isn-t-getting-the-job-done
namespace :deploy do
  desc 'Deploy app in staging environment'
  task :staging do
    Paratrooper::Deploy.new("imuastaging").deploy
  end

  desc 'Deploy app in production environment'
  task :production do
    Paratrooper::Deploy.new("imua").deploy
  end
end

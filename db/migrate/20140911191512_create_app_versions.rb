class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.integer :version_number

      t.timestamps
    end
  end
end

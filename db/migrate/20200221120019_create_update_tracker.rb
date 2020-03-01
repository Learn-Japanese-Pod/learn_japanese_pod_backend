class CreateUpdateTracker < ActiveRecord::Migration[6.0]
  class UpdateTracker < ApplicationRecord
    self.table_name = :update_tracker
  end  

  def change
    create_table :update_tracker do |t|
      t.string :feed_name, null: false
      t.datetime :last_episode_at
    end

    UpdateTracker.create(feed_name: "learn_japanese_pod_2020")
  end
end

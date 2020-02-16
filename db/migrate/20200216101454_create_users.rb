class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :push_token, unique: true, index: true

      t.timestamps
    end
  end
end

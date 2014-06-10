class CreateUsermeetups < ActiveRecord::Migration
  def change
    create_table :usermeetups do |table|
      table.integer :user_id, null: false
      table.integer :meetup_id, null: false
    end
    add_index :usermeetups, [:user_id, :meetup_id], unique: true
  end
end

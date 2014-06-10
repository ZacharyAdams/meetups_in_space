class CreateMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |table|
      table.string :name, null: false
      table.text :description
      table.string :location, null: false

      table.timestamps
    end
  end
end

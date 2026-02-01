class CreateTimeSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :time_slots do |t|
      t.datetime :starts_at, null: false
      t.integer :max_tables, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :time_slots, :starts_at
  end
end

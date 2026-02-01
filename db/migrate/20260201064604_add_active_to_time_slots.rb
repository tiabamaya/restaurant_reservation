class AddActiveToTimeSlots < ActiveRecord::Migration[8.1]
  def change
    add_column :time_slots, :active, :boolean, default: true, null: false
  end
end

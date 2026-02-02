class AddUniqueIndexToTimeSlotsStartsAt < ActiveRecord::Migration[8.1]
  def change
    add_index :time_slots, :starts_at, unique: true
  end
end
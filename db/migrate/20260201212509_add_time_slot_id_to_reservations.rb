class AddTimeSlotIdToReservations < ActiveRecord::Migration[8.1]
  # Minimal classes inside migration (safer than using app models directly)
  class MigrationReservation < ActiveRecord::Base
    self.table_name = "reservations"
  end

  class MigrationTimeSlot < ActiveRecord::Base
    self.table_name = "time_slots"
  end

  def up
    # 1) Add column nullable first (so existing rows won't break)
    add_reference :reservations, :time_slot, null: true, foreign_key: true

    # 2) Backfill existing reservations
    MigrationReservation.reset_column_information
    MigrationTimeSlot.reset_column_information

    MigrationReservation.find_each do |r|
      next if r["time_slot_id"].present?
      next if r["reserved_at"].blank?

      # IMPORTANT: round to the hour so similar times become the same slot
      starts_at = r["reserved_at"].in_time_zone.change(min: 0, sec: 0)

      slot = MigrationTimeSlot.find_by(starts_at: starts_at)
      unless slot
        slot = MigrationTimeSlot.create!(
          starts_at: starts_at,
          max_tables: 5,
          active: true
        )
      end

      r.update_columns(time_slot_id: slot.id, reserved_at: starts_at)
    end

    # 3) Now enforce NOT NULL
    change_column_null :reservations, :time_slot_id, false
  end

  def down
    remove_reference :reservations, :time_slot, foreign_key: true
  end
end

class TimeSlot < ApplicationRecord
    scope :active, -> { where(active: true) }

    def booked_count
        Reservation.booked.where(reserved_at: starts_at).count
    end

    def available_tables
        [max_tables - booked_count, 0].max
    end
end

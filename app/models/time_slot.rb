class TimeSlot < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates :starts_at, presence: true
  validates :max_tables, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalize_starts_at

  has_many :reservations, dependent: :nullify

  # ✅ Use time_slot_id (not reserved_at range)
  def booked_count
    reservations.booked.count
  end

  def max_tables_safe
    max_tables.to_i
  end

  def available_tables
    [max_tables_safe - booked_count, 0].max
  end

  def availability_label
    "#{available_tables}/#{max_tables_safe}"
  end

  #  Auto-create slots for any date user selects
  def self.ensure_for_date!(date, open_hour: 9, close_hour: 21, interval_minutes: 60, max_tables: 5)
    day = date.in_time_zone
    start_time = Time.zone.local(day.year, day.month, day.day, open_hour, 0)
    end_time   = Time.zone.local(day.year, day.month, day.day, close_hour, 0)

    t = start_time
    while t <= end_time
      find_or_create_by!(starts_at: t.change(sec: 0)) do |ts|
        ts.max_tables = max_tables
        ts.active = true
      end
      t += interval_minutes.minutes
    end
  end

  private

  def normalize_starts_at
    # Keep slots clean: HH:00:00
    self.starts_at = starts_at&.in_time_zone&.change(min: 0, sec: 0)
  end
end

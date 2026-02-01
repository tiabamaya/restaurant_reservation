class TimeSlot < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates :starts_at, presence: true
  validates :max_tables, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalize_starts_at

  def booked_count
    Reservation.booked.where(reserved_at: starts_at..(starts_at + 59.minutes + 59.seconds)).count
  end

  def available_tables
    return 0 if max_tables.nil?
    [max_tables - booked_count, 0].max
  end

  private

  def normalize_starts_at
    self.starts_at = starts_at&.change(sec: 0)
  end
end

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :time_slot

  validates :party_size, presence: true,
                         numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }

  enum :status, { booked: 0, cancelled: 1 }
  scope :booked, -> { where(status: :booked) }

  validates :time_slot, presence: true
  validates :party_size, presence: true, numericality: { greater_than: 0 }
  validates :contact_name, presence: true
  validates :contact_phone, presence: true

  before_validation :sync_reserved_at_from_slot

  validate :must_be_at_least_two_hours_ahead, if: :enforce_booking_rules?
  validate :slot_must_have_available_tables, if: :enforce_booking_rules?

  def cancellable?
    reserved_at.present? && reserved_at >= 2.hours.from_now
  end

  private

  def enforce_booking_rules?
    booked? && (new_record? || will_save_change_to_time_slot_id?)
  end

  def must_be_at_least_two_hours_ahead
    return if time_slot.blank?

    if time_slot.starts_at < 2.hours.from_now
      errors.add(:time_slot, "must be at least 2 hours from now.")
    end
  end

  def slot_must_have_available_tables
    return if time_slot.blank?

    if time_slot.available_tables <= 0
      errors.add(:time_slot, "is fully booked.")
    end
  end

  def sync_reserved_at_from_slot
    self.reserved_at = time_slot&.starts_at
  end
end

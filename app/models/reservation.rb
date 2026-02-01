class Reservation < ApplicationRecord
  belongs_to :user

  enum :status, { booked: 0, cancelled: 1 }
  scope :booked, -> { where(status: :booked) }

  validates :reserved_at, presence: true
  validates :party_size, presence: true, numericality: { greater_than: 0 }
  validates :contact_name, presence: true
  validates :contact_phone, presence: true

  validate :must_be_at_least_two_hours_ahead, if: :enforce_booking_rules?
  validate :slot_must_have_available_tables, if: :enforce_booking_rules?


  def cancellable?
    reserved_at.present? && reserved_at >= 2.hours.from_now
  end


  private

  def enforce_booking_rules?
    booked? && (new_record? || will_save_change_to_reserved_at?)
  end

  def must_be_at_least_two_hours_ahead
    return if reserved_at.blank?

    if reserved_at < 2.hours.from_now
      errors.add(:reserved_at, "must be at least 2 hours from now.") if reserved_at < 2.hours.from_now
    end
  end

  def slot_must_have_available_tables
    return if reserved_at.blank?

    normalized_time = reserved_at.change(sec: 0)

    slot = TimeSlot.find_by(starts_at: reserved_at)
    return errors.add(:reserved_at, "is not a valid slot.") if slot.nil?

    errors.add(:reserved_at, "is fully booked.") if slot.available_tables <= 0
  end
end

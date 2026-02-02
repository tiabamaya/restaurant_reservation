class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_availability, only: [:new, :confirm, :create]

  def index
    @reservations = current_user.reservations.order(reserved_at: :asc)
  end

  def show
    @reservation = current_user.reservations.find(params[:id])
  end

  def new
    @reservation = current_user.reservations.new
  end

  def confirm
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.status = :booked

    if @reservation.valid?
      render :confirm
    else
      flash.now[:alert] = @reservation.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.status = :booked

    if @reservation.save
      redirect_to confirmation_reservation_path(@reservation), notice: "Reservation booked!"
    else
      flash.now[:alert] = @reservation.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
    @reservation = current_user.reservations.find(params[:id])
  end

  def destroy
    reservation = current_user.reservations.find(params[:id])

    unless reservation.cancellable?
      redirect_to reservations_path, alert: "You can only cancel at least 2 hours before the reservation time."
      return
    end

    reservation.update(status: :cancelled)
    redirect_to reservations_path, notice: "Reservation cancelled."
  end

  private

  def reservation_params
    params.require(:reservation).permit(:date, :time_slot_id, :party_size, :contact_name, :contact_phone)
  end

def load_availability
  @selected_date =
    if params[:date].present?
      Date.parse(params[:date]) rescue Date.current
    elsif params.dig(:reservation, :time_slot_id).present?
      TimeSlot.find(params[:reservation][:time_slot_id]).starts_at.to_date rescue Date.current
    else
      Date.current
    end

  @selected_date = Date.current if @selected_date < Date.current

  # ✅ Ensure slots exist for chosen date
  TimeSlot.ensure_for_date!(@selected_date, open_hour: 9, close_hour: 21, interval_minutes: 60, max_tables: 5)

  day_range = @selected_date.beginning_of_day..@selected_date.end_of_day
  @time_slots = TimeSlot.active
                        .where(starts_at: day_range)
                        .where("starts_at >= ?", 2.hours.from_now)
                        .order(:starts_at)
end

  #  This removes the "7-day limit" problem because slots get created on demand
  def ensure_time_slots_for(date)
    day_range = date.beginning_of_day..date.end_of_day
    return if TimeSlot.where(starts_at: day_range).exists?

    # example: 9AM to 9PM (adjust if you want)
    start_hour = 9
    end_hour   = 21

    (start_hour..end_hour).each do |h|
      starts_at = date.in_time_zone.change(hour: h, min: 0, sec: 0)

      TimeSlot.create!(
        starts_at: starts_at,
        max_tables: 5,
        active: true
      )
    end
  end
end

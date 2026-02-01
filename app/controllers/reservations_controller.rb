class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_availability, only: [:new, :confirm]

  def index
    @reservations = current_user.reservations.order(reserved_at: :asc)
  end

  def show
    @reservation = current_user.reservations.find(params[:id])
  end

  def new
    @reservation = current_user.reservations.new
  end

  # Step 1: Review page (not saved yet)
  def confirm
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.status = :booked

    if @reservation.valid?
      render :confirm
    else
      flash.now[:alert] = @reservation.errors.full_messages.first
      load_availability
      render :new, status: :unprocessable_entity
    end
  end

  # Step 2: Final submit (saved here)
  def create
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.status = :booked

    if @reservation.save
      redirect_to confirmation_reservation_path(@reservation), notice: "Reservation booked!"
    else
      load_availability
      flash.now[:alert] = @reservation.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
    @reservation = current_user.reservations.find(params[:id])
  end

  # Soft cancel
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
    params.require(:reservation).permit(:reserved_at, :party_size, :contact_name, :contact_phone)
  end

  # This runs for new/confirm/create so NEW never crashes when re-rendered
 def load_availability
    # keep the date stable (today -> next 6 days), so Feb 1 won't disappear
    @dates = (Date.current..(Date.current + 6.days)).to_a

    # selected date priority:
    # 1) params[:date]
    # 2) reservation reserved_at (when form submitted)
    # 3) today
    if params[:date].present?
      @selected_date = Date.parse(params[:date])
    elsif params.dig(:reservation, :reserved_at).present?
      @selected_date = Time.zone.parse(params[:reservation][:reserved_at]).to_date rescue Date.current
    else
      @selected_date = Date.current
    end

    day_range = @selected_date.beginning_of_day..@selected_date.end_of_day
    @time_slots = TimeSlot.active.where(starts_at: day_range).order(:starts_at)
  end
end

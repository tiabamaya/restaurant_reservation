class Admin::ReservationsController < Admin::BaseController
  before_action :set_date, only: [:index]

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    range = @date.beginning_of_day..@date.end_of_day

    @reservations = Reservation.includes(:user)
                               .where(reserved_at: range)
                               .order(:reserved_at)
  end

  def cancel
    reservation = Reservation.find(params[:id])
    reservation.update(status: :cancelled)
    redirect_to admin_reservations_path(date: reservation.reserved_at.to_date), notice: "Reservation cancelled."
  end

  private

  def set_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
  end
end

class Admin::ReservationsController < Admin::BaseController
  before_action :set_date, only: [:index]

  def index
    range = @date.beginning_of_day..@date.end_of_day

    @reservations = Reservation.includes(:user, :time_slot)
                               .where(reserved_at: range)
                               .order(:reserved_at)
  end

  def cancel
    reservation = Reservation.find(params[:id])
    reservation.update(status: :cancelled)

    redirect_to admin_reservations_path(date: reservation.reserved_at.to_date),
                notice: "Reservation cancelled."
  end

  def destroy
    reservation = Reservation.find(params[:id])
    date = reservation.reserved_at&.to_date || Date.current
    reservation.destroy
    redirect_back fallback_location: admin_dashboard_path(date: date),
                  notice: "Reservation deleted."
  end

  # GET /admin/calendar
  def calendar
  @month = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month

  start_day = @month.beginning_of_month.beginning_of_week(:sunday)
  end_day   = @month.end_of_month.end_of_week(:sunday)

  range = start_day.beginning_of_day..end_day.end_of_day

  # DO NOT generate the whole month (keeps it fast)
  # Only show slots that already exist in DB
  @time_slots = TimeSlot.active.where(starts_at: range).order(:starts_at)

  booked_counts = Reservation.booked.where(reserved_at: range).group(:reserved_at).count

  @availability_by_time = {}
  @time_slots.each do |slot|
    booked = booked_counts[slot.starts_at].to_i
    @availability_by_time[slot.starts_at] = [slot.max_tables.to_i - booked, 0].max
  end

  @slots_by_date = @time_slots.group_by { |s| s.starts_at.to_date }
end


    range = month_start.beginning_of_day..month_end.end_of_day

    # One query for slots
    @time_slots = TimeSlot.active.where(starts_at: range).order(:starts_at)

    # One query for booked counts
    booked_counts = Reservation.booked.where(reserved_at: range).group(:reserved_at).count

    # Availability per slot (datetime key)
    @availability_by_time = {}
    @time_slots.each do |slot|
      booked = booked_counts[slot.starts_at].to_i
      @availability_by_time[slot.starts_at] = [slot.max_tables.to_i - booked, 0].max
    end

    # Slots grouped by date for rendering
    @slots_by_date = @time_slots.group_by { |s| s.starts_at.to_date }
  end

  private

  def set_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
  end
end

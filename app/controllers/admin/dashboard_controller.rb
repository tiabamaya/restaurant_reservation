class Admin::DashboardController < Admin::BaseController
  def index
    @date  = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @month = @date.beginning_of_month

    # calendar range (full weeks)
    @cal_start = @month.beginning_of_week(:sunday)
    @cal_end   = @month.end_of_month.end_of_week(:sunday)
    @calendar_days = (@cal_start..@cal_end).to_a

    # ensure slots exist for the selected date (so table never empty)
    TimeSlot.ensure_for_date!(@date, max_tables: 5)

    # ensure slots exist for the month being viewed
    (@month.beginning_of_month..@month.end_of_month).each do |d|
      TimeSlot.ensure_for_date!(d, max_tables: 5)
    end

    # Build daily availability summary used for calendar colors
    @daily_summary = {}

    @calendar_days.each do |day|
      day_range = day.beginning_of_day..day.end_of_day

      slots = TimeSlot.active.where(starts_at: day_range)

      total_tables = slots.sum { |s| s.max_tables.to_i }
      available_tables = slots.sum { |s| s.available_tables.to_i }

      percent_available =
        if total_tables.zero?
          0.0
        else
          (available_tables.to_f / total_tables.to_f) * 100.0
        end

      @daily_summary[day] = {
        total_tables: total_tables,
        available_tables: available_tables,
        percent_available: percent_available
      }
    end

    # time slots for the selected day (show both active + inactive)
    day_range = @date.beginning_of_day..@date.end_of_day
    @time_slots = TimeSlot.where(starts_at: day_range).order(:starts_at)

    # show reservations for a selected slot
    if params[:slot_id].present?
      @selected_slot = TimeSlot.find(params[:slot_id])

      all = Reservation.includes(:user)
                       .where(reserved_at: @selected_slot.starts_at)
                       .order(:id)

      @booked_reservations = all.select(&:booked?)
      @cancelled_reservations = all.select(&:cancelled?)
    end
  end
end

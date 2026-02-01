class Admin::TimeSlotsController < Admin::BaseController
  before_action :set_date, only: [:index]
  before_action :set_time_slot, only: [:edit, :update, :toggle_active]

  def index
    range = @date.beginning_of_day..@date.end_of_day
    @time_slots = TimeSlot.where(starts_at: range).order(:starts_at)
  end

  def new
    base_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @time_slot = TimeSlot.new(
      starts_at: base_date.in_time_zone.change(hour: 9, min: 0),
      max_tables: 5,
      active: true
    )
  end

  def create
    @time_slot = TimeSlot.new(time_slot_params)

    if @time_slot.save
      redirect_to admin_time_slots_path(date: @time_slot.starts_at.to_date), notice: "Time slot created."
    else
      flash.now[:alert] = @time_slot.errors.full_messages.first
      set_date
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @time_slot.update(time_slot_params)
      redirect_to admin_time_slots_path(date: @time_slot.starts_at.to_date), notice: "Time slot updated."
    else
      flash.now[:alert] = @time_slot.errors.full_messages.first
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_active
    @time_slot.update(active: !@time_slot.active)
    redirect_to admin_time_slots_path(date: @time_slot.starts_at.to_date), notice: "Slot updated."
  end

  private

  def set_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
  end

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:starts_at, :max_tables, :active)
  end
end

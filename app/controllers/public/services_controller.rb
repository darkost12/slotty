module Public
  class ServicesController < BaseController
    DAYS_AHEAD = 14

    def show
      @service = @master.services.active.find(params.expect(:id))
      @days = Date.current...(Date.current + DAYS_AHEAD)
      @date = selected_date
      @slots = AvailableSlots.new(service: @service, date: @date).call
    end

    private

    # ?date=2026-11-02. A broken date or one outside the window falls back to today.
    def selected_date
      date = Date.iso8601(params[:date].to_s)
      @days.cover?(date) ? date : @days.first
    rescue Date::Error
      @days.first
    end
  end
end

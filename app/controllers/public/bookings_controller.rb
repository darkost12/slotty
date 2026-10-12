module Public
  class BookingsController < BaseController
    SLOT_TAKEN = "is no longer available. Please pick another time".freeze

    before_action :set_service

    def new
      @booking = @service.bookings.new(starts_at: params[:starts_at])

      redirect_to public_service_path(@master.slug, @service) if @booking.starts_at.nil?
    end

    def create
      @booking = @service.bookings.new(booking_params)

      if slot_available? && @booking.save
        redirect_to public_master_path(@master.slug),
          notice: "You're booked: #{@service.name}, #{l(@booking.starts_at, format: :long)}."
      else
        render :new, status: :unprocessable_content
      end
    rescue ActiveRecord::ExclusionViolation
      @booking.errors.add(:starts_at, SLOT_TAKEN)
      render :new, status: :unprocessable_content
    end

    private

    def set_service
      @service = @master.services.active.find(params.expect(:service_id))
    end

    # No user, status or ends_at here: the model fills them in itself.
    def booking_params
      params.expect(booking: %i[starts_at client_name client_email])
    end

    # The client can send any time in the form, so we accept only times AvailableSlots offers.
    # Two clients can still pass this check at the same moment — the exclusion constraint catches that, see rescue in create.
    def slot_available?
      starts_at = @booking.starts_at
      return true if starts_at.nil? # the presence validation will report it
      return true if AvailableSlots.new(service: @service, date: starts_at.to_date).call.include?(starts_at)

      @booking.errors.add(:starts_at, SLOT_TAKEN)
      false
    end
  end
end

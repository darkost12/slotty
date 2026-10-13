# The master's own bookings. Clients book through Public::BookingsController.
class BookingsController < ApplicationController
  def index
    # includes(:service): load all services in one query instead of one per booking (N+1).
    @bookings = Current.user.bookings.upcoming.includes(:service)
  end

  def cancel
    booking = Current.user.bookings.find(params.expect(:id))
    booking.cancelled!

    redirect_to bookings_path, notice: "Booking cancelled.", status: :see_other
  end
end

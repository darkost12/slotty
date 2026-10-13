class BookingMailer < ApplicationMailer
  # Sent to the client right after they book.
  def confirmation(booking)
    @booking = booking
    @service = booking.service
    @master = booking.user

    mail to: booking.client_email,
      subject: "You're booked: #{@service.name}, #{l(booking.starts_at, format: :long)}"
  end
end

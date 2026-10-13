# Open http://localhost:<port>/rails/mailers/booking_mailer/confirmation in development.
class BookingMailerPreview < ActionMailer::Preview
  def confirmation
    BookingMailer.confirmation(Booking.last || raise("Create a booking first"))
  end
end

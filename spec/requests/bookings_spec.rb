require "rails_helper"

RSpec.describe "Bookings", type: :request do
  let(:user) { create(:user) }
  let(:service) { create(:service, user: user, name: "Haircut") }

  context "when signed out" do
    it "redirects to sign in" do
      get bookings_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in" do
    before { sign_in(user) }

    describe "GET /bookings" do
      it "lists the user's upcoming bookings" do
        create(:booking, service: service, client_name: "Anna")
        create(:booking, service: create(:service), client_name: "Someone else's client")

        get bookings_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Anna", "Haircut")
        expect(response.body).not_to include("Someone else's client")
      end
    end

    describe "PATCH /bookings/:id/cancel" do
      it "cancels the user's booking" do
        booking = create(:booking, service: service)

        patch cancel_booking_path(booking)

        expect(response).to redirect_to(bookings_path)
        expect(booking.reload).to be_cancelled
      end

      it "cannot cancel someone else's booking" do
        booking = create(:booking, service: create(:service))

        patch cancel_booking_path(booking)

        expect(response).to have_http_status(:not_found)
        expect(booking.reload).to be_confirmed
      end
    end
  end
end

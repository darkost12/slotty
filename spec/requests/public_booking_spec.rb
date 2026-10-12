require "rails_helper"

RSpec.describe "Public booking", type: :request do
  let(:master) { create(:user) }
  let(:service) { create(:service, user: master, name: "Haircut", duration_minutes: 30) }

  # Sunday morning; the master works on Monday 10:00–11:00.
  before do
    travel_to Time.zone.parse("2026-11-01 09:00")
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")
  end

  def at(time) = Time.zone.parse("2026-11-02 #{time}")

  describe "GET /book/:slug" do
    it "lists the master's active services" do
      service
      create(:service, user: master, name: "Old massage", active: false)
      create(:service, name: "Other master's manicure")

      get public_master_path(master.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Haircut")
      expect(response.body).not_to include("Old massage")
      expect(response.body).not_to include("Other master's manicure")
    end

    it "returns 404 for an unknown slug" do
      get public_master_path("nobody-here")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /book/:slug/services/:id" do
    it "shows free slots for the chosen date" do
      get public_service_path(master.slug, service, date: "2026-11-02")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("10:00", "10:15", "10:30")
    end

    it "returns 404 for an inactive service" do
      service.update!(active: false)

      get public_service_path(master.slug, service)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for another master's service" do
      get public_service_path(create(:user).slug, service)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /book/:slug/services/:service_id/bookings" do
    def book(starts_at)
      post public_service_bookings_path(master.slug, service), params: {
        booking: { starts_at: starts_at.iso8601, client_name: "Anna", client_email: "anna@example.com" }
      }
    end

    it "books a free slot" do
      expect { book(at("10:15")) }.to change(master.bookings, :count).by(1)

      expect(response).to redirect_to(public_master_path(master.slug))
      expect(master.bookings.last).to have_attributes(
        service: service, starts_at: at("10:15"), ends_at: at("10:45"), status: "confirmed"
      )
    end

    it "rejects a time that is not on the grid" do
      expect { book(at("10:05")) }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a slot that is already taken" do
      create(:booking, service: service, starts_at: at("10:00"))

      expect { book(at("10:15")) }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("no longer available")
    end

    it "shows an error when the slot was taken at the same moment" do
      create(:booking, service: service, starts_at: at("10:00"))
      allow_any_instance_of(AvailableSlots).to receive(:call).and_return([at("10:00")])

      expect { book(at("10:00")) }.not_to change(Booking, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("no longer available")
    end
  end
end

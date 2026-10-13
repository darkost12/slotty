require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "#confirmation" do
    let(:service) { create(:service, name: "Haircut", duration_minutes: 30) }
    let(:booking) do
      create(:booking, service: service, client_name: "Anna", client_email: "anna@example.com",
                       starts_at: Time.zone.parse("2026-11-02 10:00"))
    end

    subject(:mail) { described_class.confirmation(booking) }

    it "is sent to the client" do
      expect(mail.to).to eq(["anna@example.com"])
      expect(mail.subject).to include("Haircut")
    end

    it "contains the booking details and a link back to the master's page", :aggregate_failures do
      [mail.html_part, mail.text_part].each do |part|
        body = part.body.decoded

        expect(body).to include("Anna", "Haircut", "10:00", "10:30")
        expect(body).to include("/book/#{service.user.slug}")
      end
    end
  end
end

require "rails_helper"

# == Schema Information
#
# Table name: bookings
#
#  id           :bigint           not null, primary key
#  client_email :string           not null
#  client_name  :string(100)      not null
#  ends_at      :datetime         not null
#  starts_at    :datetime         not null
#  status       :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  service_id   :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_bookings_on_service_id             (service_id)
#  index_bookings_on_user_id_and_starts_at  (user_id,starts_at)
#
# Foreign Keys
#
#  fk_rails_...  (service_id => services.id)
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Booking, type: :model do
  subject { build(:booking) }

  def at(time) = Time.zone.parse("2026-11-02 #{time}")

  it "has a valid factory" do
    expect(create(:booking)).to be_persisted
  end

  it { is_expected.to belong_to(:service) }
  it { is_expected.to validate_presence_of(:client_name) }
  it { is_expected.to validate_length_of(:client_name).is_at_most(100) }
  it { is_expected.to validate_presence_of(:client_email) }
  it { is_expected.not_to allow_value("not-an-email").for(:client_email) }
  it { is_expected.to define_enum_for(:status).with_values(confirmed: 0, cancelled: 1).validating }

  it "is confirmed by default" do
    expect(Booking.new).to be_confirmed
  end

  it "takes the master from the service" do
    service = create(:service)

    expect(build(:booking, service: service).tap(&:valid?).user).to eq(service.user)
  end

  it "computes the end from the service duration" do
    service = create(:service, duration_minutes: 45)
    booking = build(:booking, service: service, starts_at: Time.zone.parse("2026-11-02 10:00"))

    booking.valid?

    expect(booking.ends_at).to eq(Time.zone.parse("2026-11-02 10:45"))
  end

  it "normalizes the client email" do
    expect(build(:booking, client_email: " Anna@Example.COM ").client_email).to eq("anna@example.com")
  end

  it "rejects a service of another master" do
    booking = build(:booking, user: create(:user), service: create(:service))

    expect(booking).not_to be_valid
    expect(booking.errors[:service]).to include("belongs to another master")
  end

  it "rejects an end before the start" do
    booking = build(:booking, starts_at: Time.zone.parse("2026-11-02 10:00"), ends_at: Time.zone.parse("2026-11-02 09:00"))

    expect(booking).not_to be_valid
  end

  describe ".overlapping" do
    let(:service) { create(:service) }
    let!(:booking) do
      create(:booking, service: service,
                       starts_at: Time.zone.parse("2026-11-02 10:00"),
                       ends_at: Time.zone.parse("2026-11-02 11:00"))
    end

    def overlapping(from, to)
      Booking.overlapping(Time.zone.parse("2026-11-02 #{from}"), Time.zone.parse("2026-11-02 #{to}"))
    end

    it "finds a partial overlap" do
      expect(overlapping("10:30", "11:30")).to include(booking)
    end

    it "does not find a touching interval" do
      expect(overlapping("11:00", "12:00")).to be_empty
    end

    it "ignores cancelled bookings" do
      booking.cancelled!

      expect(overlapping("10:30", "11:30")).to be_empty
    end
  end

  describe "double booking protection" do
    let(:service) { create(:service, duration_minutes: 30) }

    let(:existing) { create(:booking, service:, starts_at: at("10:00")) }

    before { existing }

    it "rejects an overlapping booking of the same master" do
      expect { create(:booking, service:, starts_at: at("10:15")) }
        .to raise_error(ActiveRecord::ExclusionViolation)
    end

    it "allows a booking right after another" do
      expect { create(:booking, service:, starts_at: at("10:30")) }.not_to raise_error
    end

    it "allows the time of a cancelled booking" do
      existing.cancelled!

      expect { create(:booking, service:, starts_at: at("10:15")) }
        .not_to raise_error
    end

    it "allows the same time for another master" do
      expect {
        create(:booking, service: create(:service, duration_minutes: 30), starts_at: at("10:15"))
      }.not_to raise_error
    end
  end
end

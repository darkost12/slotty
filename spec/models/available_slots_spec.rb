require "rails_helper"

RSpec.describe AvailableSlots do
  let(:monday) { Date.new(2026, 11, 2) }
  let(:master) { create(:user) }
  let(:service) { create(:service, user: master, duration_minutes: 30) }
  let(:now) { Time.zone.parse("2026-11-01 09:00") }

  subject(:slots) { described_class.new(service:, date: monday, now:).call }

  def at(time) = Time.zone.parse("2026-11-02 #{time}")

  it "returns nothing on a day without working hours" do
    expect(slots).to eq([])
  end

  it "cuts an interval into slots by the step" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")

    expect(slots).to eq([at("10:00"), at("10:15"), at("10:30")])
  end

  it "doesn't fit" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "10:20")

    expect(slots).to eql([])
  end

  it "fits several intervals" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "10:30")
    create(:availability_rule, user: master, weekday: :monday, start_time: "14:30", end_time: "15:00")

    expect(slots).to eql([at("10:00"), at("14:30")])
  end

  it "subtracts existing booking" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "12:00")
    create(:booking, service:, user: master, starts_at: at("10:15"), ends_at: at("10:45"))

    expect(slots).to eql([at("10:45"), at("11:00"), at("11:15"), at("11:30")])
  end

  it "allows adjoining bookings" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")
    create(:booking, service:, user: master, starts_at: at("10:00"), ends_at: at("10:30"))

    expect(slots).to eql([at("10:30")])
  end

  it "ignores cancelled booking" do
    create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")
    create(:booking, service:, user: master, starts_at: at("10:00"), ends_at: at("10:30"), status: 'cancelled')

    expect(slots).to eql([at("10:00"), at("10:15"), at("10:30")])
  end

  context "another master" do
    let(:another_service) { create(:service, duration_minutes: 30) }

    it "ignores another master" do
      create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")
      create(:booking, service: another_service, starts_at: at("10:00"), ends_at: at("10:30"))

      expect(slots).to eql([at("10:00"), at("10:15"), at("10:30")])
    end
  end

  context "now" do
    let(:now) { Time.zone.parse("2026-11-02 10:15") }

    it "skips passed time" do
      create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")

      expect(slots).to eql([at("10:15"), at("10:30")])
    end
  end

  it "ignores different week day" do
    create(:availability_rule, user: master, weekday: :tuesday, start_time: "10:00", end_time: "11:00")

    expect(slots).to eql([])
  end

  context 'another service booked' do
    let(:another_service) { create(:service, user: master, duration_minutes: 30) }

    it 'keeps another service in mind' do
      create(:availability_rule, user: master, weekday: :monday, start_time: "10:00", end_time: "11:00")
      create(:booking, service: another_service, user: master, starts_at: at("10:00"), ends_at: at("10:30"))

      expect(slots).to eql([at("10:30")])
    end
  end
end

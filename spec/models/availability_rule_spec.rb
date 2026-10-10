require "rails_helper"

# == Schema Information
#
# Table name: availability_rules
#
#  id         :bigint           not null, primary key
#  end_time   :time             not null
#  start_time :time             not null
#  weekday    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_availability_rules_on_user_id_and_weekday  (user_id,weekday)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe AvailabilityRule, type: :model do
  subject { build(:availability_rule) }

  it "has a valid factory" do
    expect(create(:availability_rule)).to be_persisted
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }

  it do
    is_expected.to define_enum_for(:weekday)
      .with_values(sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6)
      .validating
  end

  describe "end time after start time" do
    it "is invalid when end time equals start time" do
      rule = build(:availability_rule, start_time: "10:00", end_time: "10:00")

      expect(rule).not_to be_valid
      expect(rule.errors[:end_time]).to include("must be after start time")
    end

    it "is invalid when end time is before start time" do
      rule = build(:availability_rule, start_time: "14:00", end_time: "10:00")

      expect(rule).not_to be_valid
    end
  end

  describe "overlapping intervals" do
    let(:user) { create(:user) }
    let!(:existing) { create(:availability_rule, user: user, weekday: :monday, start_time: "10:00", end_time: "14:00") }

    def rule(weekday: :monday, start_time:, end_time:, owner: user)
      build(:availability_rule, user: owner, weekday: weekday, start_time: start_time, end_time: end_time)
    end

    it "rejects a partial overlap" do
      expect(rule(start_time: "13:00", end_time: "15:00")).not_to be_valid
    end

    it "rejects an interval inside the existing one" do
      expect(rule(start_time: "11:00", end_time: "12:00")).not_to be_valid
    end

    it "rejects an interval covering the existing one" do
      expect(rule(start_time: "09:00", end_time: "15:00")).not_to be_valid
    end

    it "allows an interval that touches the existing one" do
      expect(rule(start_time: "14:00", end_time: "16:00")).to be_valid
    end

    it "allows the same hours on another day" do
      expect(rule(weekday: :tuesday, start_time: "13:00", end_time: "15:00")).to be_valid
    end

    it "allows the same hours for another user" do
      expect(rule(start_time: "13:00", end_time: "15:00", owner: create(:user))).to be_valid
    end

    it "does not treat a saved interval as overlapping itself" do
      expect(existing).to be_valid
    end
  end
end

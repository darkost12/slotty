require 'rails_helper'

# == Schema Information
#
# Table name: services
#
#  id               :bigint           not null, primary key
#  active           :boolean          default(TRUE), not null
#  description      :text
#  duration_minutes :integer          not null
#  name             :string(100)      not null
#  price            :decimal(8, 2)    not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_services_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Service, type: :model do
  subject { build(:service) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:price) }
  it { is_expected.to validate_presence_of(:duration_minutes) }
  it { is_expected.to allow_value("0" * 100).for(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to allow_value("480").for(:duration_minutes) }
  it { is_expected.not_to allow_value("0" * 101).for(:name) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  it do
    is_expected
      .to validate_numericality_of(:duration_minutes)
      .is_greater_than(0).is_less_than_or_equal_to(480).only_integer
  end

  it "has a valid factory" do
    expect(create(:service)).to be_persisted
  end
end

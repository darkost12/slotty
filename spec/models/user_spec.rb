require 'rails_helper'

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to validate_uniqueness_of(:email_address).ignoring_case_sensitivity }
  it { is_expected.to allow_value("a@b.co").for(:email_address) }
  it { is_expected.not_to allow_value("not-an-email").for(:email_address) }
  it { is_expected.to validate_length_of(:password).is_at_least(8) }
  it { is_expected.to have_many(:services).dependent(:destroy) }

  it "normalizes email" do
    expect(build(:user, email_address: " Me@Example.COM ").email_address).to eq("me@example.com")
  end
end

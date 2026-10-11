require 'rails_helper'

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  slug            :string(40)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_slug           (slug) UNIQUE
#
RSpec.describe User, type: :model do
  subject { build(:user) }

  it { is_expected.to validate_presence_of(:email_address) }
  describe "email uniqueness" do
    # A saved record: the matcher would otherwise save one itself with
    # save(validate: false), which skips the callback that assigns the slug.
    subject { create(:user) }

    it { is_expected.to validate_uniqueness_of(:email_address).ignoring_case_sensitivity }
  end
  it { is_expected.to allow_value("a@b.co").for(:email_address) }
  it { is_expected.not_to allow_value("not-an-email").for(:email_address) }
  it { is_expected.to validate_length_of(:password).is_at_least(8) }
  it { is_expected.to have_many(:services).dependent(:destroy) }

  it "normalizes email" do
    expect(build(:user, email_address: " Me@Example.COM ").email_address).to eq("me@example.com")
  end

  describe "slug" do
    it "is generated from the email on create" do
      expect(create(:user, email_address: "anna.smith@example.com").slug).to eq("anna-smith")
    end

    it "gets a number when the name is taken" do
      create(:user, email_address: "anna@example.com")

      expect(create(:user, email_address: "anna@other.com").slug).to eq("anna-2")
    end

    it "is padded when the email name is too short" do
      expect(create(:user, email_address: "al@example.com").slug).to eq("master-al")
    end

    it "keeps a slug that was given explicitly" do
      expect(create(:user, slug: "best-barber").slug).to eq("best-barber")
    end

    it "rejects characters outside a-z, 0-9 and dash" do
      expect(build(:user, slug: "anna smith!")).not_to be_valid
    end

    it "must be unique" do
      create(:user, slug: "taken")

      expect(build(:user, slug: "taken")).not_to be_valid
    end
  end
end

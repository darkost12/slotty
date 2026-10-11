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
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  # Bookings go first: services refuse to be destroyed while they have bookings.
  has_many :bookings, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :availability_rules, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Public booking page address: /book/<slug>
  validates :slug, presence: true, uniqueness: true, length: { in: 3..40 },
                   format: { with: /\A[a-z0-9-]+\z/, message: "may contain only lowercase letters, digits and dashes" }
  normalizes :slug, with: ->(s) { s.strip.downcase }
  before_validation :assign_slug, on: :create

  private

  # "anna.smith@example.com" -> "anna-smith", then "anna-smith-2" if taken.
  def assign_slug
    return if slug.present? || email_address.blank?

    base = email_address.split("@").first.parameterize.tr("_", "-").first(30)
    base = "master-#{base}" if base.length < 3
    candidate = base
    number = 1
    while User.exists?(slug: candidate)
      number += 1
      candidate = "#{base}-#{number}"
    end
    self.slug = candidate
  end
end

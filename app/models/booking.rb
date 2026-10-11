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
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :service

  enum :status, { confirmed: 0, cancelled: 1 }, default: :confirmed, validate: true

  normalizes :client_email, with: ->(email) { email.strip.downcase }

  before_validation :copy_user_from_service
  before_validation :set_ends_at_from_service

  validates :client_name, presence: true, length: { maximum: 100 }
  validates :client_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_at_after_starts_at
  validate :service_belongs_to_user

  # Confirmed bookings that take up the master's time somewhere between from and to.
  # Same overlap rule as in AvailabilityRule: touching intervals do not overlap.
  scope :overlapping, ->(from, to) { confirmed.where("starts_at < ? AND ends_at > ?", to, from) }

  private

  # The master is always the owner of the service.
  def copy_user_from_service
    self.user ||= service&.user
  end

  # A booking lasts as long as its service at the moment of booking.
  def set_ends_at_from_service
    return if ends_at.present? || starts_at.blank? || service.nil?

    self.ends_at = starts_at + service.duration_minutes.minutes
  end

  def ends_at_after_starts_at
    if starts_at && ends_at && ends_at <= starts_at
      errors.add(:ends_at, "must be after start time")
    end
  end

  def service_belongs_to_user
    if service && user && !service.user_id.eql?(user_id)
      errors.add(:service, "belongs to another master")
    end
  end
end

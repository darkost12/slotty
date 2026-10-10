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
class AvailabilityRule < ApplicationRecord
  belongs_to :user

  enum :weekday, {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }, validate: true

  # Order for display: the week starts on Monday in the UI,
  # while the stored numbers follow Ruby's Date#wday (Sunday = 0).
  DISPLAY_ORDER = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :end_time_after_start_time
  validate :no_overlap_with_other_rules

  private

  def end_time_after_start_time
    if start_time && end_time && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlap_with_other_rules
    return if user_id.nil? || weekday.blank? || start_time.blank? || end_time.blank?

    overlapping =
      AvailabilityRule
        .where(user_id: user_id, weekday: weekday)
        .where.not(id: id)
        .where("start_time < ? AND end_time > ?", end_time, start_time)
        .exists?

    if overlapping
      errors.add(:base, "overlaps with another interval on the same day")
    end
  end
end

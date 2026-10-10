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
FactoryBot.define do
  factory :availability_rule do
    user
    weekday { :monday }
    start_time { "10:00" }
    end_time { "14:00" }
  end
end

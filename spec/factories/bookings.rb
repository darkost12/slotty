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
FactoryBot.define do
  factory :booking do
    service
    starts_at { 1.day.from_now.change(hour: 10, min: 0) }
    client_name { "Anna" }
    sequence(:client_email) { |n| "client#{n}@example.com" }
    # user and ends_at are filled in by the model from the service
  end
end

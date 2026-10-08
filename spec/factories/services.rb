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
FactoryBot.define do
  factory :service do
    sequence(:name) { |n| "service#{n}" }
    duration_minutes { 30 }
    price { 9.99 }
    user
  end
end

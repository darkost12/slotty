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
class Service < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 100 }
  validates :duration_minutes, presence: true,
    numericality: { greater_than: 0, less_than_or_equal_to: 480, only_integer: true }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end

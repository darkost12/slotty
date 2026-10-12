class AddNoOverlapConstraintToBookings < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    add_exclusion_constraint :bookings,
      "user_id WITH =, tsrange(starts_at, ends_at, '[)') WITH &&",
      using: :gist,
      where: "status = 0", # 0 = confirmed
      name: "bookings_no_overlap"
  end
end

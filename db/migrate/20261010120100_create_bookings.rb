class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      # user_id duplicates service.user_id on purpose: the master's bookings
      # must not overlap across all services, and a database constraint
      # can only compare columns of the same table.
      t.references :user, null: false, foreign_key: true, index: false
      t.references :service, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :client_name, null: false, limit: 100
      t.string :client_email, null: false
      t.integer :status, null: false, default: 0, limit: 2

      t.timestamps

      t.index [:user_id, :starts_at]
      t.check_constraint "ends_at > starts_at", name: "bookings_end_after_start"
      t.check_constraint "status IN (0, 1)", name: "bookings_status_values"
    end
  end
end

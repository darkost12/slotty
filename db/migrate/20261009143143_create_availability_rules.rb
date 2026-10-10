class CreateAvailabilityRules < ActiveRecord::Migration[8.1]
  def change
    create_table :availability_rules do |t|
      t.integer :weekday, null: false, limit: 2
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.references :user, null: false, foreign_key: true, index: false

      t.index [:user_id, :weekday]

      t.check_constraint "weekday >= 0 and weekday <= 6",
        name: "availability_rules_weekday_range"
      t.check_constraint "end_time > start_time",
        name: "availability_rules_end_after_start"
      t.timestamps
    end
  end
end

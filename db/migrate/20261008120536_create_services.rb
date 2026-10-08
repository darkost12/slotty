class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name, null: false, limit: 100
      t.integer :duration_minutes, null: false
      t.decimal :price, null: false, precision: 8, scale: 2
      t.text :description
      t.boolean :active, null: false, default: true
      t.references :user, null: false, foreign_key: true

      t.check_constraint "duration_minutes > 0 and duration_minutes <= 480",
        name: "services_duration_minutes_range"
      t.check_constraint "price >= 0", name: "services_price_non_negative"
      t.timestamps
    end
  end
end

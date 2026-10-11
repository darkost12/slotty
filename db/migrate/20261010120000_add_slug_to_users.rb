class AddSlugToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :slug, :string, limit: 40

    # Existing users get "<email name>-<id>": unique and valid by construction.
    execute <<~SQL
      UPDATE users
      SET slug = trim(both '-' from regexp_replace(lower(split_part(email_address, '@', 1)), '[^a-z0-9]+', '-', 'g')) || '-' || id
    SQL

    change_column_null :users, :slug, false
    add_index :users, :slug, unique: true
    add_check_constraint :users, "slug ~ '^[a-z0-9-]+$'", name: "users_slug_format"
  end

  def down
    remove_column :users, :slug
  end
end

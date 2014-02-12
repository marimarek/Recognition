class CreateDigits < ActiveRecord::Migration
  def change
    create_table :digits do |t|
      t.integer :digit_recognize
      t.integer :digit_user_marked
      t.integer :user_id

      t.timestamps
    end
    add_index :digits, [:user_id, :created_at]
  end
end

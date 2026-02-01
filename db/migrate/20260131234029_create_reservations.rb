class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :reserved_at
      t.integer :party_size
      t.string :contact_name
      t.string :contact_phone
      t.integer :status

      t.timestamps
    end
  end
end

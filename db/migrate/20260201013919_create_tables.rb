class CreateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.integer :capacity, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end

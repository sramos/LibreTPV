class CreateAlbarans < ActiveRecord::Migration
  def self.up
    create_table :albarans do |t|
      t.string :codigo
      t.date :fecha
      t.boolean :cerrado, :default => false
      t.integer :proveedor_id
      t.integer :cliente_id

      t.timestamps
    end
  end

  def self.down
    drop_table :albarans
  end
end

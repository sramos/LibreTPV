class CreateAlbaranLineas < ActiveRecord::Migration
  def self.up
    create_table :albaran_lineas do |t|
      t.integer :cantidad
      t.integer :descuento
      t.integer :producto_id
      t.integer :albaran_id

      t.timestamps
    end
  end

  def self.down
    drop_table :albaran_lineas
  end
end

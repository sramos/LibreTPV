class CreateAlbaranLineas < ActiveRecord::Migration
  def self.up
    create_table :albaran_lineas do |t|
      t.integer :cantidad, :default => 1
      t.integer :descuento, :default => 0
      t.decimal :precio_compra, :precision => 8, :scale => 2, :default => 0
      t.decimal :precio_venta, :precision => 8, :scale => 2, :default => 0
      t.integer :producto_id
      t.integer :albaran_id

      t.timestamps
    end
  end

  def self.down
    drop_table :albaran_lineas
  end
end

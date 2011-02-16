class CreateAlbaranLineas < ActiveRecord::Migration
  def self.up
    create_table :albaran_lineas do |t|
      t.integer :cantidad
      t.integer :descuento

      t.timestamps
    end
  end

  def self.down
    drop_table :albaran_lineas
  end
end

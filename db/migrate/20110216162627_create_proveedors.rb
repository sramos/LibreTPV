class CreateProveedors < ActiveRecord::Migration
  def self.up
    create_table :proveedors do |t|
      t.string :nombre
      t.string :direccion
      t.string :email
      t.string :telefono
      t.string :contacto
      t.integer :descuento, :default => 0
      t.string :cif

      t.timestamps
    end
  end

  def self.down
    drop_table :proveedors
  end
end

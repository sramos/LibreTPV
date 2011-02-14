class CreateProveedores < ActiveRecord::Migration
  def self.up
    create_table :proveedores do |t|
      t.string :nombre
      t.string :cif

      t.timestamps
    end
  end

  def self.down
    drop_table :proveedores
  end
end

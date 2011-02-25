class CreateFamilias < ActiveRecord::Migration
  def self.up
    create_table :familias do |t|
      t.string :nombre
      t.integer :iva_id
      t.ingeger :campo_id

      t.timestamps
    end
  end

  def self.down
    drop_table :familias
  end
end

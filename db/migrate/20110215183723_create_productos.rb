class CreateProductos < ActiveRecord::Migration
  def self.up
    create_table :productos do |t|
      t.integer :codigo
      t.string :nombre
      t.string :descripcion
      t.string :url_imagen
      t.integer :familia_id

      t.timestamps
    end
  end

  def self.down
    drop_table :productos
  end
end

class CreateProductos < ActiveRecord::Migration
  def self.up
    create_table :productos do |t|
      t.string :codigo
      t.string :nombre
      t.string :autor
      t.string :editor
      t.string :anno
      t.string :descripcion
      t.string :url_imagen
      t.decimal :precio, :precision => 8, :scale => 2, :null => false
      t.integer :cantidad, :default => 0
      t.integer :familia_id

      t.timestamps
    end
  end

  def self.down
    drop_table :productos
  end
end

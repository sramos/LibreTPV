class CreateProductoEditorialXAlmacen < ActiveRecord::Migration
  def change
    create_table :producto_editorial_x_almacenes do |t|
      t.references :producto_editorial
      t.references :almacen
      t.integer :cantidad, null: false, default: 0
      t.timestamps
    end
  end
end

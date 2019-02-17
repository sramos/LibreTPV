class CreateProductoEditorial < ActiveRecord::Migration
  def change
    create_table :productos_editorial do |t|
      t.references :producto, foreign_key: true
      t.timestamps
    end
  end
end

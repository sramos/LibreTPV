class CreateProductoEditorial < ActiveRecord::Migration
  def change
    create_table :producto_editorial do |t|
      t.references :producto, foreign_key: true
      t.integer :cantidad, :default => 0

      t.timestamps
    end
  end
end

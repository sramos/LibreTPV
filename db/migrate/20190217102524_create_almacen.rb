class CreateAlmacen < ActiveRecord::Migration
  def change
    create_table :almacenes do |t|
      t.string :nombre
      t.timestamps
    end
  end
end

class AddImagenToProductos < ActiveRecord::Migration
  def up
    add_attachment :productos, :imagen
  end

  def down
    remove_attachment :productos, :imagen
  end
end

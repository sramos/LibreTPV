class AddPrecioToProducto < ActiveRecord::Migration
  def self.up
    add_column :productos, :precio, :decimal
  end

  def self.down
    remove_column :productos, :precio
  end
end

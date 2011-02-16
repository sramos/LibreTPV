class AddPrecioToProducto < ActiveRecord::Migration
  def self.up
    add_column :productos, :precio, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :productos, :precio
  end
end

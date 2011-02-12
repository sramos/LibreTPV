class AddCamposToProducto < ActiveRecord::Migration
  def self.up
    add_column :productos, :codigo, :integer
    add_column :productos, :nombre, :string
    add_column :productos, :descripcion, :string
    add_column :productos, :imagen, :string
    add_column :productos, :cantidad, :integer
  end

  def self.down
    remove_column :productos, :cantidad
    remove_column :productos, :imagen
    remove_column :productos, :descripcion
    remove_column :productos, :nombre
    remove_column :productos, :codigo
  end
end

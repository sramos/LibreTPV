class AddDireccionToCliente < ActiveRecord::Migration
  def self.up
    add_column :clientes, :direccion, :string
    add_column :clientes, :cp, :string
  end

  def self.down
    remove_column :clientes, :direccion
    remove_column :clientes, :cp
  end
end

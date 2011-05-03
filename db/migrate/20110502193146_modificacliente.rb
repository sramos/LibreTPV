class Modificacliente < ActiveRecord::Migration
  def self.up
    add_column :clientes, :credito, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :clientes, :credito
  end
end

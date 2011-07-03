class AddCreditoAcumuladoToProducto < ActiveRecord::Migration
  def self.up
    add_column :clientes, :credito_acumulado, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :clientes, :credito_acumulado
  end
end

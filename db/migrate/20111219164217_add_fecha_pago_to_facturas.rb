class AddFechaPagoToFacturas < ActiveRecord::Migration
  def self.up
    add_column :facturas, :fecha_vencimiento, :date
  end

  def self.down
    remove_column :facturas, :fecha_vencimiento
  end
end

class AddImportesToFactura < ActiveRecord::Migration
  def self.up
    add_column :facturas, :importe_base, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :facturas, :importe_base
  end
end

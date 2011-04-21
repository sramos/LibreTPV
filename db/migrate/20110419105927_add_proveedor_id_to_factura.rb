class AddProveedorIdToFactura < ActiveRecord::Migration
  def self.up
    add_column :facturas, :proveedor_id, :integer
    add_column :facturas, :valor_iva, :integer
    add_column :facturas, :valor_irpf, :integer
    change_column :facturas, :albaran_id, :integer, {:null=>true}
  end

  def self.down
    remove_column :facturas, :proveedor_id
    remove_column :facturas, :valor_iva
    remove_column :facturas, :valor_irpf
    change_column :facturas, :albaran_id, :integer, {:null=>false}
  end
end

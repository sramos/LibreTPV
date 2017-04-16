class AddIndexes1 < ActiveRecord::Migration
  def change
    add_index :albaran_lineas, [:albaran_id], name: :albaran_lineas_idx
    add_index :albaran_lineas, [:producto_id], name: :albaran_lineas_producto_idx
    add_index :albarans, [:proveedor_id, :cliente_id], name: :albarans_idx
    add_index :albarans, [:factura_id], name: :albarans_factura_idx
    add_index :facturas, [:proveedor_id], name: :factura_idx
    add_index :autor_x_producto, [:producto_id, :autor_id], name: :autor_x_producto_idx
  end
end

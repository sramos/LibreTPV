class CreaCamposLineasAlbaran < ActiveRecord::Migration
  def self.up
    # Incluye los nuevos campos
    add_column :albaran_lineas, :nombre_producto, :string
    add_column :albaran_lineas, :iva, :integer
    change_column_default(:albaran_lineas, :precio_compra, nil)
    change_column_default(:albaran_lineas, :precio_venta, nil) 
    # Introduce el valor que deberian tener los nuevos campos
    AlbaranLinea.all.each do |al|
      if (al.producto)
        al.iva = al.producto.familia.iva.valor if al.producto.familia && al.producto.familia.iva
        al.nombre_producto = al.producto.nombre
        al.precio_venta = al.producto.precio if al.albaran && !al.albaran.cliente_id.nil?
        al.save
      end
    end
  end

  def self.down
    remove_column :albaran_lineas, :nombre_producto
    remove_column :albaran_lineas, :iva
    change_column_default(:albaran_lineas, :precio_compra, 0.0)
    change_column_default(:albaran_lineas, :precio_venta, 0.0)
  end
end

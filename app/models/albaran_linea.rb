class AlbaranLinea < ActiveRecord::Base

  belongs_to :producto
  belongs_to :albaran

  after_create :mete_campos


  # devuelve el subtotal (sin iva)
  def subtotal
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra
    else
      precio = self.precio_venta / (1 + self.iva.to_f/100)
      #precio = self.producto.precio / (1 + self.producto.familia.iva.valor.to_f/100)
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  # devuelve el total (con iva)
  def total
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra * (1 + self.iva.to_f/100)
    else
      precio = self.precio_venta
      #precio = self.producto.precio
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  private
    # Mete automaticamente los campos que se necesiten si la linea esta vinculada a un producto
    def mete_campos
      if self.producto
        self.precio_venta = self.producto.precio if !self.albaran.cliente.nil?
        self.iva = self.producto.familia.iva.valor
        self.nombre_producto = self.producto.nombre 
        self.save
      end
    end
end

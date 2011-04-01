class AlbaranLinea < ActiveRecord::Base

  belongs_to :producto
  belongs_to :albaran

  # devuelve el subtotal.
  def subtotal
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra * self.cantidad * (1 - self.descuento.to_f/100)
      #precio = self.precio_compra * (1 - self.producto.familia.iva.valor.to_f/100)
    else
      precio = self.producto.precio * self.cantidad * (1 - self.descuento.to_f/100) / (1 + self.producto.familia.iva.valor.to_f/100)
    end
    return precio 
  end

  def total
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra * (1 + self.producto.familia.iva.valor.to_f/100)
    else
      precio = self.producto.precio
    end
    return self.cantidad * precio * (1 - self.descuento.to_f/100)
  end
end

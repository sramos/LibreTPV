class AlbaranLinea < ActiveRecord::Base

  belongs_to :producto
  belongs_to :albaran

  # devuelve el subtotal.
  def subtotal
    if ( self.precio_compra != 0 )
      precio = self.precio_compra
      #precio = self.precio_compra * (1 - self.producto.familia.iva.valor.to_f/100)
    else
      precio = self.producto.precio
    end
    return self.cantidad * precio * (1 - self.descuento.to_f/100)
  end

end

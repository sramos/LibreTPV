class AlbaranLinea < ActiveRecord::Base

  belongs_to :producto
  belongs_to :albaran

  #validate :comprueba_linea
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
    def comprueba_linea
      # Comprueba que exista producto asociado, o sea entrada por concepto
      if self.producto.nil? 
        errors.add( "albaran_linea", "No se introdujo el concepto" ) unless self.nombre_producto
        errors.add( "albaran_linea", "No se introdujo el tipo de IVA aplicado" ) unless self.iva
        errors.add( "albaran_linea", "No se introdujo el precio" ) unless self.precio_compra || self.precio_venta
      end
      return false unless errors.empty?
    end

    # Mete automaticamente los campos que se necesiten si la linea esta vinculada a un producto
    def mete_campos
      if self.producto
        self.precio_venta = self.producto.precio if !self.albaran.cliente.nil?
        self.iva = self.producto.familia.iva.valor
        self.nombre_producto = self.producto.nombre 
      else
        self.nombre_producto = "N/A" unless self.nombre_producto && self.nombre_producto != ""
      end
      self.save
    end
end

class Albaran < ActiveRecord::Base

  # No utilizamos el dependent por evitar borrados dobles en las lineas
  #has_many :albaran_lineas, :dependent => :destroy
  has_many :albaran_lineas
  belongs_to :cliente
  belongs_to :proveedor
  #has_one :factura
  belongs_to :factura

  before_destroy :verificar_facturas, :borra_lineas_normales
  before_update :borra_lineas_descuento, :if => "cliente_id_changed? && !cerrado"
  after_update :cierra_albaran_cliente, :if => "cliente_id && factura_id_changed? && factura_id_was.nil? && !cerrado"

  # Crea un albaran copiando todos los datos de otro
  def clonar
    #albaran = clone
    #albaran.albaran_lineas = albaran_lineas.collect {|al| al.clone}
    albaran = Albaran.create(self.attributes.merge({:codigo => "D-"+codigo, :cerrado => false, :fecha => Date.today}))
    self.albaran_lineas.each do |al|
      albaran.albaran_lineas << AlbaranLinea.create(al.attributes)
    end
    albaran
  end

  # Cierra un albaran modificando los productos del inventario
  def cerrar seccion
    if seccion != "tesoreria" && !self.cerrado
      if seccion == "productos"
        multiplicador = 1
      else
        multiplicador = -1
      end 
      # Actualiza el inventario y el credito del cliente
      inventario_y_credito multiplicador
      # Cambia el estado del albaran a abierto
      self.cerrado = true 
      self.save
    end
  end

  # Reabre un albaran modificando los productos del inventario
  def reabrir seccion
    if seccion != "tesoreria" && self.cerrado
      if seccion == "productos"
        multiplicador = -1
      else
        multiplicador = 1
      end 
      # Actualiza el inventario y el credito del cliente
      inventario_y_credito multiplicador
      # Cambia el estado del albaran a abierto
      self.cerrado = false
      self.factura_id = nil
      self.save
    end
  end

  # Devuelve la base imponible de los productos
  def base_imponible
    subtotal = 0
    lineas = self.albaran_lineas
    lineas.each do |linea|
      subtotal += linea.subtotal
    end
    return subtotal
  end

  # Devuelve la suma del iva aplicado en los productos
  def iva_aplicado
    iva_total = 0
    lineas = self.albaran_lineas
    lineas.each do |linea|
      iva_total += (linea.total-linea.subtotal)
    end
    return iva_total
  end

  # Devuelve el iva aplicado segun los tipos
  def desglose_por_iva
    desglose = Hash.new
    self.albaran_lineas.each do |linea|
      desglose[linea.iva.to_s] = [0,0,0] if desglose[linea.iva.to_s].nil?
      desglose[linea.iva.to_s][0] += linea.subtotal*100.to_i.to_f/100
      desglose[linea.iva.to_s][1] += (linea.total-linea.subtotal)*100.to_i.to_f/100
      desglose[linea.iva.to_s][2] += linea.total*100.to_i.to_f/100
    end
    return desglose 
  end

  # Devuelve la suma de los dos anteriores
  def total
    return self.iva_aplicado + self.base_imponible
  end

  # Devuelve un codigo detallado
  def codigo_detallado
    prefijo = "("
    prefijo += (self.cerrado ? "C" : "A") unless deposito
    prefijo += "D" if deposito
    return prefijo + ") " + codigo
  end

  private
    # Cierra un albaran de cliente despues de haberse asignado factura
    def cierra_albaran_cliente
      self.cerrado = true
      self.save
    end

    def verificar_borrado
      if !self.pagos.empty?
        errors.add( "factura", "No se puede borrar la factura: Hay pagos realizados." ) unless self.pagos.empty?
        false
      end
    end

  private
    def verificar_facturas
      if !self.factura.nil?
        errors.add( "albaran", "No se puede borrar albaran: Hay facturas asociadas." )
        false
      end
    end

    # Borra las lineas de albaran relacionadas que no sean de descuento
    def borra_lineas_normales
      self.albaran_lineas.all(:conditions => { :linea_descuento_id => nil }).each { |al| al.destroy }
    end

    def borra_lineas_descuento
      self.albaran_lineas.all(:conditions => ["linea_descuento_id IS NOT NULL"]).each { |al| al.destroy }
    end

    # Hace los calculos de las lineas de albaran
    def inventario_y_credito multiplicador
      # Obtiene el credito inicial se es una venta/devolucion
      total_credito = (self.cliente.credito_acumulado || 0) if self.cliente
      self.albaran_lineas.each do |linea|
        # En el caso de que haya un producto asociado, lo modifica en el inventario
        if linea.producto
          producto=linea.producto
          producto.cantidad += (linea.cantidad * multiplicador)
          producto.save
          # En el caso de que sea una venta/devolucion, incluye el credito
          total_credito += (-1 * multiplicador * linea.total * linea.producto.familia.acumulable/100) if self.cliente
        end
      end  
      # Actualiza el credito total si es una venta/devolucion y no es caja
      if self.cliente && self.cliente_id != 1 && self.cliente.credito_acumulado != total_credito
          self.cliente.credito_acumulado = total_credito
          self.cliente.save
      end
    end

end

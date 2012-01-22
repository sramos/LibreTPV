class Avisos < ActiveRecord::Base

  
  # Metodos incluidos a la clase 
  class << self
    def activos(visible=true)
      Avisos.all :conditions => { :visible => visible }, :order => "criticidad desc"
    end

    def depositos_no_devueltos
      Albaran.all(:conditions => ["cerrado AND fecha_devolucion < ? AND deposito", Date.today]).each do |deposito|
        diferencia = (deposito.fecha_devolucion - Time.now.to_date).abs.to_s
        valores = { :objeto => "deposito", :objeto_id => deposito.id, :url => "/productos/deposito/listado" }
        aviso = Avisos.first(:conditions => valores ) || Avisos.new(valores)
        aviso.mensaje = "Hay un depósito de " + deposito.proveedor.nombre + " (" + deposito.codigo + ") que debería haberse devuelto hace " + diferencia + " días!"
        aviso.criticidad = 3
        aviso.save
      end
    end
    def proxima_devolucion_depositos(dias=nil)
      dias ||= 7
      Albaran.all(:conditions => ["cerrado AND fecha_devolucion >= ? AND fecha_devolucion <= ?",Date.today,(Date.today+dias.days)]).each do |deposito|
        diferencia = (deposito.fecha_devolucion - Time.now.to_date).abs.to_s
        valores = { :objeto => "deposito", :objeto_id => deposito.id, :url => "/productos/deposito/listado" }
        aviso = Avisos.first(:conditions => valores ) || Avisos.new(valores)
        aviso.mensaje = "Hay un depósito de " + deposito.proveedor.nombre + " (" + deposito.codigo + ") a devolver en " + diferencia + " días."
        aviso.criticidad = 2
        aviso.save
      end
    end

    def proximos_vencimientos_facturas(dias=nil)
      dias ||= 7
      Factura.all(:conditions => [ "fecha_vencimiento >= ? AND fecha_vencimiento <= ? AND NOT pagado", Time.now, (Time.now+dias.days)]).each do |factura|
        diferencia = (Time.now.to_date - factura.fecha_vencimiento).abs.to_s
        valores = { :objeto => "factura", :objeto_id => factura.id, :url => "/productos/factura/listado" }
        aviso = Avisos.first(:conditions => valores ) || Avisos.new(valores)
        aviso.mensaje = "Una factura vencerá en " + diferencia + " días"
        aviso.criticidad = 1
        aviso.save
      end
    end
    def facturas_vencidas
      Factura.all(:conditions => ["fecha_vencimiento < ? AND NOT pagado", Time.now.beginning_of_day]).each do |factura|
        diferencia = (factura.fecha_vencimiento - Time.now.to_date).abs.to_s
        valores = { :objeto => "factura", :objeto_id => factura.id, :url => "/productos/factura/listado" }
        aviso = Avisos.first(:conditions => valores ) || Avisos.new(valores)
        aviso.mensaje = "Hay una factura vencida hace " + diferencia + " días, que aún no está pagada"
        aviso.criticidad = 2
        aviso.save
      end
    end
  end

end

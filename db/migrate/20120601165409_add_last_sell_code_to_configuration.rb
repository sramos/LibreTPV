class AddLastSellCodeToConfiguration < ActiveRecord::Migration
  def self.up
    add_column :configuracion, :editable, :boolean, :default => true
    #ultima_factura = Factura.count(:include => ["albarans"], :conditions => ["albarans.cliente_id IS NOT NULL"])
    #Configuracion.create(:nombre_param => "FACTURAS VENTA", :valor_param => ultima_factura.to_s, :editable => false) if ultima_factura
    impresion = Configuracion.find_by_nombre_param("COMANDO IMPRESION")
    if impresion
      impresion.editable = false
      impresion.save
    end
  end

  def self.down
    remove_column :configuracion, :editable
    #Configuracion.find_by_nombre_param("FACTURAS VENTA").destroy
  end
end


scheduler = Rufus::Scheduler.start_new

#scheduler.every("1m") do
#  Test.check_thumbnails!
#end

# Comprueba las facturas
scheduler.every("1m") do
  Factura.vencidas.each do |factura|
    diferencia = (factura.fecha_vencimiento - Time.now.to_date).abs.to_s
    valores = { :objeto => "Factura", :objeto_id => factura.id, :url => "/productos/factura/listado" }
    aviso = Avisos.first(:conditions => valores )
    aviso ||= Avisos.new(valores)
    aviso.mensaje = "Hay una factura vencida hace " + diferencia + " días, que aún no está pagada!"
    aviso.criticidad = 3
    aviso.save
  end
  Factura.proximos_vencimientos.each do |factura|
    diferencia = (Time.now.to_date - factura.fecha_vencimiento).abs.to_s
    valores = { :objeto => "Factura", :objeto_id => factura.id, :url => "/productos/factura/listado" }
    aviso = Avisos.first(:conditions => valores )
    aviso ||= Avisos.new(valores)
    aviso.mensaje = "Una factura vencerá en " + diferencia + " días"
    aviso.criticidad = 2
    aviso.save
  end
end


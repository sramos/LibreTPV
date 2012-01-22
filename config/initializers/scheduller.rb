
scheduler = Rufus::Scheduler.start_new

#scheduler.every("1m") do
#  Test.check_thumbnails!
#end

# Chequeo en el arranque
Avisos.depositos_no_devueltos
Avisos.proxima_devolucion_depositos
Avisos.proximos_vencimientos_facturas
Avisos.facturas_vencidas

# Comprueba las facturas
scheduler.every("6h") do
  Avisos.depositos_no_devueltos
  Avisos.proxima_devolucion_depositos
  Avisos.proximos_vencimientos_facturas
  Avisos.facturas_vencidas
end


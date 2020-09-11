#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2019 Santiago Ramos <sramos@sitiodistinto.net>
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo
#    bajo los términos de la Licencia Pública General GNU publicada
#    por la Fundación para el Software Libre, ya sea la versión 3
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO.
#    Consulte los detalles de la Licencia Pública General GNU para obtener
#    una información más detallada.
#
#    Debería haber recibido una copia de la Licencia Pública General GNU
#    junto a este programa.
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++

module ListadoHelper

  #--
  # METODOS GENERALES
  #++
  def campos_listado tipo
    case tipo
      when "inventario"
        ["codigo", "familia.nombre", "nombre", "autores", "cantidad", "precio"]
      when "inventario_deposito"
        ["producto.cantidad", "cantidad", "producto.nombre", "producto.autores", "albaran.proveedor.nombre", "albaran.fecha_devolucion", "producto.precio"]
      when "inventario_distribuidora"
        ["codigo", "familia.nombre", "nombre", "autores", "producto_editorial.cantidad", "precio"]
      when "inventario_almacen"
        ["producto.codigo", "producto.familia.nombre", "producto.nombre", "producto.autores", "cantidad"]
      when "almacenes_de_producto_editorial"
        ["almacen.nombre", "cantidad"]
      when "proveedores"
        ["cif", "nombre", "telefono", "email", "descuento"]
      when "clientes"
        ["cif", "nombre", "email", "descuento","credito","credito_acumulado"]
      when "albaranes_productos"
        ["fecha", "proveedor.nombre", "codigo"]
      when "albaranes_cerrados_compra"
        ["fecha", "codigo", "proveedor.nombre", "base_imponible", "iva_aplicado", "total"]
      when "albaranes_clientes"
        ["fecha", "cliente.nombre"]
      when "depositos_productos"
        ["fecha", "proveedor.nombre", "codigo", "fecha_devolucion"]
      when "depositos_clientes"
        ["fecha", "cliente.nombre", "fecha_devolucion"]
      when "facturas_productos"
        ["fecha", "fecha_vencimiento", "codigo_mayusculas", "albarans.first.proveedor.nombre", "base_imponible", "iva_aplicado", "importe"]
      when "facturas_caja"
        ["fecha", "codigo_mayusculas", "albarans.first.cliente.nombre", "base_imponible", "iva_aplicado", "importe"]
      when "facturas_tesoreria"
        ["fecha", "codigo", "proveedor.nombre", "base_imponible", "valor_iva", "valor_irpf", "importe"]
      when "arqueo_caja"
        ["ventas", "compras", "pagos_servicios", "entradas/salidas", "total caja"]
      when "libro_diario"
        ["fecha", "concepto", "codigo", "debe", "haber"]
      when "movimientos_caja"
        ["fecha_hora","importe","comentarios"]
      when "avisos"
	      ["criticidad", "mensaje", "visible", "updated_at"]
      when "lineas_compra"
        ["cantidad","producto.codigo","nombre_producto","precio_compra","descuento","subtotal","iva", "total"]
      when "lineas_deposito"
        ["producto.cantidad","cantidad","producto.codigo","nombre_producto","precio_compra","descuento","subtotal","iva", "total"]
      when "lineas_venta"
        ["cantidad","producto.codigo","nombre_producto","precio_venta","descuento","subtotal","iva", "total"]
      when "productos_vendidos"
        ["albaran.factura.fecha","cantidad","producto.codigo","producto.nombre","albaran.factura.codigo"]
      when "productos_comprados"
        ["albaran.fecha","cantidad","producto.codigo", "nombre_producto","albaran.factura.codigo"]
      when "lista_reposicion"
        ["nombre_producto","fecha_devolucion"]
      when "resumen_facturas_servicios"
        ["fecha", "codigo", "proveedor.nombre", "importe"]
      when "resumen_facturas_compras"
        ["fecha", "codigo", "albarans.first.proveedor.nombre", "importe"]
      when "resumen_facturas_ventas"
        ["fecha", "codigo", "albarans.first.cliente.nombre", "importe"]
      when "pagos"
        ["fecha","importe","forma_pago.nombre"]
      when "compras_producto"
        ["fecha","codigo_detallado","factura.codigo","proveedor.nombre"]
      when "ventas_producto"
        ["fecha","factura.codigo","cliente.nombre"]
      when "configuracion"
        ["nombre_param","valor_param"]
      when "perdidos_compra"
        ["fecha", "proveedor.nombre", "codigo", "base_imponible", "iva_aplicado", "total"]
      when "perdidos_venta"
        ["fecha", "cliente.nombre", "base_imponible", "iva_aplicado", "total"]
      when "familias"
        ["nombre", "iva.nombre", "sincroniza_web", "acumulable"]
      when "iva"
        ["nombre","valor"]
      when "materias"
        ["familia.nombre", "nombre", "valor_defecto"]
      when "editoriales"
        ["nombre", "producto.count"]
      when "autores"
        ["nombre", "autor_x_producto.count"]
      when "productos_autor"
        ["codigo", "familia.nombre", "nombre", "autores", "cantidad"]
      when "formas_pago"
        ["nombre", "caja"]
      when "almacen"
        ["nombre"]
      when "users"
        ["name", "email", "user_sections"]
    end
  end

  def campos_info tipo
    case tipo
      when "proveedores"
        ["direccion", "contacto"]
    end
  end

  def etiqueta campo
    etiqueta = {	"albaran.cliente.nombre"	=> ["Cliente", "1", 36],
			"albaran.proveedor.nombre"	=> ["Proveedor", "2_3", 20],
			"albarans.first.cliente.nombre"	=> ["Cliente", "1", 36],
			"albarans.first.proveedor.nombre" => ["Proveedor", "2_3", 20],
      "almacen.nombre" => ["Almacen", "1", 36],
			"cliente.nombre"		=> ["Cliente", "1", 36],
			"familia.nombre"		=> ["Familia", "1_2", 15],
			"proveedor.nombre"		=> ["Proveedor", "1", 36],
			"codigo"			=> ["Código", "2_3", 20],
      "codigo_mayusculas"             => ["Código", "2_3", 20],
			"producto.codigo"		=> ["Código/ISBN", "1_2", 15],
			"producto.nombre"		=> ["Nombre/Título", "1", 36],
			"producto.cantidad"		=> ["Stock", "1_5", 8, "d"],
			"producto.autores"		=> ["Autor", "2_3", 20],
      "producto.familia.nombre" => ["Familia", "1_2", 15],
			"nombre_producto"		=> ["Nombre/Título", "1", 36],
			"nombre"			=> ["Nombre/Título", "1", 36],
			"autores"			=> ["Autor", "2_3", 20],
			"producto.precio"		=> ["PVP", "1_4", 14, "f"],
			"cantidad"			=> ["Cant.", "1_5", 8, "d"],
			"precio"			=> ["PVP", "1_4", 14, "f"],
			"subtotal"			=> ["Subtotal", "1_4", 14, "f"],
			"descuento"			=> ["% Dto.", "1_5", 8, "d"],
			"producto.familia.iva.valor"	=> ["% IVA", "1_5", 8, "d"],
			"iva.nombre"			=> ["IVA aplicado", "1", 36],
			"iva"				=> ["% IVA", "1_5", 8, "d"],
			"iva_aplicado"			=> ["IVA", "1_4", 14, "f"],
			"precio_compra"			=> ["P.Prov.", "1_4", 14, "f"],
			"precio_venta"			=> ["PVP", "1_4", 14, "f"],
			"total"				=> ["Total", "1_4", 14, "f"],
			"forma_pago.nombre"		=> ["Forma de Pago", "1", 36],
			"factura.codigo"		=> ["Código de Factura", "2_3", 20],
			"albaran.factura.codigo"	=> ["Código de Factura", "2_3", 20],
			"albaran.factura.fecha"		=> ["Fecha", "1_2", 15],
			"albaran.codigo"		=> ["Código de Albarán", "2_3", 20],
			"albaran.codigo_detallado"	=> ["Código de Albarán", "2_3", 20],
			"codigo_detallado"		=> ["Código de Albarán", "2_3", 20],
			"albaran.fecha"			=> ["Fecha", "1_2", 15],
			"fecha_devolucion"		=> ["Devolución", "1_2", 15],
			"fecha_vencimiento"		=> ["Vencimiento", "1_2", 15],
			"albaran.fecha_devolucion"	=> ["Devolución", "1_2", 15],
			"email"			      	=> ["email", "2_3", 20],
			"nombre_param"			=> ["Parámetro","1", 36],
			"valor_param"			=> ["Valor", "1", 36],
			"base_imponible"		=> ["Base Imp.", "1_3", 14, "f"],
			"valor_iva"			=> ["%IVA", "1_5", 8, "d"],
			"valor_irpf"			=> ["%IRPF", "1_5", 8, "d"],
			"acumulable"			=> ["% Reemb.", "1_4", 14, "d"],
			"importe"			=> ["Importe", "1_4", 14, "f"],
			"concepto"			=> ["Concepto", "1", 36],
			"debe"				=> ["Debe", "1_3", 14, "f"],
			"haber"				=> ["Haber", "1_3", 14, "f"],
			"iva soportado"			=> ["Iva Soportado", "1", 36],
			"iva repercutido"		=> ["Iva Repercutido", "1", 36],
			"base_imponible_por_iva"	=> ["Base Imp.", "1_3", 14, "f"],
			"total_iva"			=> ["Total Iva", "1_3", 14, "f"],
			"importe_total"			=> ["Total Bruto", "1_3", 14, "f"],
			"fecha_hora"			=> ["Fecha", "2_3", 20],
			"comentarios"			=> ["Observaciones", "1", 36],
      "ventas"			=> ["Ventas", "2_3", 20, "f"],
			"compras"			=> ["Compras", "2_3", 20, "f"],
			"pagos_servicios"		=> ["Otros Gastos", "2_3", 20, "f"],
			"entradas/salidas"		=> ["Entradas/Salidas", "2_3", 20, "f"],
			"total caja"			=> ["Total Caja", "2_3", 20, "f"],
      "credito"			=> ["Crédito", "1_3", 14, "f"],
			"credito_acumulado"		=> ["Acumulado", "1_3", 14, "f"],
			"direccion"			=> ["Dirección", "1", 36],
			"contacto"			=> ["Dirección", "1", 36],
			"mensaje"			=> ["Mensaje", "1", 36],
			"updated_at"			=> ["Modificado", "2_3", 20],
      "autor_x_producto.count"        => ["Núm.Productos", "1_4", 14, "d"],
      "producto.count"                => ["Núm.Productos", "1_4", 14, "d"],
      "valor_defecto"                 => ["Valor por defecto", "2_3", 20],
      "name"                          => ["Nombre", "1", 48],
      "user_sections"                 => ["Permisos", "1", 48],
		}
    return etiqueta[campo] || [campo.humanize, "1_2", 15]
  end

end

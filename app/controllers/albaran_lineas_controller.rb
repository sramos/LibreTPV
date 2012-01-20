class AlbaranLineasController < ApplicationController


  # Metodos AJAX de Lineas de Albaran

  def lineas
    albaran = Albaran.find(params[:albaran_id])
    @albaran_lineas = albaran.albaran_lineas 

    @formato_xls = true
    respond_to do |format|
      format.xls do
        @tipo = "lineas_deposito" if albaran.proveedor && albaran.deposito
        @tipo = "lineas_compra" if albaran.proveedor && !albaran.deposito
        @tipo = "lineas_venta" unless albaran.proveedor
        codigo = albaran.factura.codigo if albaran.factura && albaran.factura.codigo && albaran.factura.codigo != "N/A"
        codigo ||= albaran.codigo+" (*)"
        fecha = (albaran.factura ? albaran.factura.fecha.to_s : nil) || albaran.fecha.to_s
        fecha += " / Fecha Devolución: " + albaran.fecha_devolucion.to_s if albaran.deposito
        @xls_head = "Venta " + codigo + " / Cliente: " + albaran.cliente.nombre + " / Fecha: " + fecha if albaran.cliente
        @xls_head = (albaran.deposito ? "Depósito: " : "Factura: ") + codigo + " / Proveedor: " + albaran.proveedor.nombre + " / Fecha: " + fecha if albaran.proveedor
        @xls_head += "  / ALBARAN ABIERTO" if !albaran.cerrado
        @objetos = @albaran_lineas
        @xls_title = "Albaran " + albaran.codigo
        render 'comunes_xls/listado', :layout => false
      end 
      format.html do
        render :update do |page|
          page.replace_html params[:update], :partial => "lineas"
        end
      end
    end
  end

  def editar
    @albaran_linea = AlbaranLinea.find(params[:id])
    render :partial => "editar", :albaran_id => params[:albaran_id]
  end

  def modificar
    @albaran_linea = AlbaranLinea.find(params[:id])
    @albaran_linea.update_attributes params[:albaran_linea]
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

  def asignar_linea
    albaran = Albaran.find_by_id params[:albaranlinea][:albaran_id]
    if albaran && !albaran.cerrado
      albaranlinea = params[:id] ? AlbaranLinea.find(params[:id]) : AlbaranLinea.new
      albaranlinea.producto_id = params[:producto][:id] if params[:producto]
      albaranlinea.update_attributes params[:albaranlinea]

      if !Albaran.find_by_id(params[:albaranlinea][:albaran_id]).proveedor.nil? && params[:precios_relacionados]
        if params[:precios_relacionados][1].to_s == "true"
          producto = Producto.find_by_id(params[:producto][:id])
          preciodeventa = producto.precio
          albaranlinea.precio_compra = preciodeventa / (1 + producto.familia.iva.valor.to_f/100)
        else
          albaranlinea.precio_compra = params[:albaranlinea][:precio_compra].to_f
        end
        albaranlinea.save
      end

    end
    #flash[:error] = albaranlinea if albaranlinea.errors
    redirect_to :controller => :albarans, :action => :editar, :id => albaranlinea.albaran_id
  end

  def borrar 
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id] 
    if albaranlinea && albaran && !albaran.cerrado
      albaranlinea.destroy
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

	# Aplica el acumulado de una linea
  def usar_acumulado
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id]
    if albaranlinea && albaran.cliente
      albaranlinea.nueva_linea_descuento
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

end

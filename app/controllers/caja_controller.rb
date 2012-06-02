class CajaController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Movimientos de Caja (Entradas/Salidas Manuales)" if params[:seccion] == 'caja'
    redirect_to :action => :listado if params[:seccion] == 'caja'
    redirect_to :action => :arqueo if params[:seccion] == 'tesoreria'
  end

  def listado
    @caja = Caja.paginate( :all, :order => 'id DESC',
        :page => (params[:format]=='xls' ? nil : params[:page]), :per_page => (params[:format_xls_count] || Configuracion.valor('PAGINADO') ))
    @formato_xls = @caja.total_entries
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "movimientos_caja"
        @objetos = @caja
        render 'comunes_xls/listado', :layout => false
      end
    end
  end

  def arqueo 
    @importe_ventas = @importe_compras = @importe_gastos = 0
    # Calcula la fecha/hora del ultimo cierre de caja
    @cierre_caja = Caja.last :conditions => { :cierre_caja => true }
    @importe_caja = @cierre_caja ? @cierre_caja.importe : 0
    # Encuentra todas las ventas en caja realizados desde el ultimo cierre de caja
    @pagos = Pago.find :all, :include => "forma_pago", :conditions => [ "forma_pagos.caja IS TRUE AND fecha > ?", (@cierre_caja ? @cierre_caja.fecha_hora : Date.new) ]
    @pagos.each do |pago|
      @importe_ventas += pago.importe if pago.factura && !pago.factura.albarans.empty? && pago.factura.albarans.first.cliente
      @importe_compras += pago.importe if pago.factura && !pago.factura.albarans.empty? && pago.factura.albarans.first.proveedor
      @importe_gastos += pago.importe if pago.factura && pago.factura.albarans.empty? && pago.factura.proveedor
      #puts "---> ERROR: Pago con id " + pago.id.to_s + " no tiene factura asociada!!!!" if pago.factura.nil?
    end
    # Encuentra todas las compras en caja realizadas desde el ultimo cierre de caja
    # Encuentra todos los pagos de servicios realizados desde el ultimo cierre de caja
    # Encuentra todas las entradas/salidas de caja realizadas desde el ultimo cierre de caja
    @salidas = Caja.find :all, :conditions => [ "fecha_hora > ?", (@cierre_caja ? @cierre_caja.fecha_hora : Date.new) ]
    @salidas.each do |salida|
      @importe_caja += salida.importe
    end
  end

  def cierre_caja
    @importe = params[:importe]
    render :partial => "cierre_caja"
  end

  def guarda_cierre_caja
    importe_real = params[:importe_real][0].to_f
    importe_teorico = params[:importe_teorico][0].to_f
    if importe_real && importe_teorico
      Caja.new( :importe => (0-importe_real), :comentarios => "Cierre de Caja", :cierre_caja => true, :fecha_hora => Time.now ).save
      if (importe_real - importe_teorico) != 0
        Caja.new( :importe => (importe_real - importe_teorico), :comentarios => "Cierre de Caja (Descuadre)", :cierre_caja => true, :fecha_hora => Time.now ).save
      end
      Caja.new( :importe => importe_real, :comentarios => "Entrada de efectivo", :cierre_caja => true, :fecha_hora => Time.now ).save
    end
    redirect_to :action => :listado
  end

  def editar
    @caja = nil
    render :partial => "formulario"
  end

  def modificar 
    @caja = Caja.new
    @caja.fecha_hora = Time.now
    @caja.update_attributes params[:caja]
    flash[:error] = @caja
    redirect_to :action => :listado
  end
  
end

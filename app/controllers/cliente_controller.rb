class ClienteController < ApplicationController

  def index
    redirect_to :action => :listado
  end

  def listado
    @clientes = Cliente.order(:nombre).
                        paginate(page: (params[:format]=='xls' ? nil : params[:page]),
                                 per_page: (params[:format_xls_count] || Configuracion.valor('PAGINADO')) )
    @formato_xls = @clientes.total_entries
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "clientes"
        @objetos = @clientes
        render 'comunes_xls/listado', :layout => false
      end
    end
  end

  def editar
    @cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    render partial: "formulario"
  end

  def modificar
    cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    cliente.update_attributes params[:cliente]
    flash[:error] = cliente
    redirect_to action: :listado
  end

  def borrar
    cliente = Cliente.find_by_id params[:id]
    cliente.destroy
    flash[:error] = cliente
    redirect_to :action => :listado
  end

  def nuevo_credito
    @cliente = params[:id] ? Cliente.find(params[:id]) : nil
    if @cliente.nil?
      flash[:error] = "Elija un clientes antes de realizar esta accion"
      redirect_to :action => :listado
    else
      render :partial => "nuevo_credito"
    end
  end

  def aumentar_credito
    cliente = params[:id] ? Cliente.find(params[:id]) : nil
    if cliente.nil?
      flash[:error] = "Elija un clientes antes de realizar esta accion"
    else
      cliente.credito = cliente.credito ? (cliente.credito + params[:aumenta_credito][0].to_f) : params[:aumenta_credito][0].to_f
      if cliente.save
        caja = Caja.new
        caja.fecha_hora = Time.now
        caja.importe = params[:aumenta_credito][0].to_f
        caja.comentarios = "Aumento de credito " + cliente.nombre
        caja.save
        flash[:error] = caja
      else
        flash[:error] = cliente
      end
    end
    redirect_to :action => :listado
  end

  # Devuelve sublistado de productos vendidos al cliente
  def productos
    albaranes = Albaran.where(cliente_id: params[:id], cerrado: true)
    # Obtiene las líneas de cada albaran del proveedor
    @lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| @lineas.push(linea) } }
    #puts "--------------->" + @lineas.to_s
    render :update do |page|
      page.replace_html params[:update], :partial => "productos"
    end
  end
end

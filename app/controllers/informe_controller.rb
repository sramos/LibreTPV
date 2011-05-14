class InformeController < ApplicationController

  require 'spreadsheet'

  def index
    flash[:mensaje] = "Listado de elementos 'Perdidos'"
    redirect_to :action => 'listado'
  end

  def listado
    @informes = [       ["Productos Vendidos", "productos_vendidos"], 
                        ["Productos Comprados", "productos_comprados"],
                        ["Facturas de Venta", "facturas_venta"],
                        ["Facturas de Compra", "facturas_compra"],
                        ["Facturas de Otros Gastos", "facturas_servicios"],
                 ]

    if params[:informe]
      redirect_to :action => params[:informe][:tipo]
    end
  end

  def productos_vendidos
    campos = [	["Fecha", "fecha"], ["Producto", "nombre"], ["Cliente", "cliente.nombre"] ]
    condicion = "albarans.cliente_id IS NOT NULL"
    objeto = AlbaranLinea.find :all, :include => "albaran", :conditions => [ condicion ]
    flash[:error] = "Informe no disponible"
    redirect_to :action => 'listado'
  end

  def productos_comprados
    flash[:error] = "Informe no disponible"
    redirect_to :action => 'listado'
  end

  def facturas_venta
    flash[:error] = "Informe no disponible"
    redirect_to :action => 'listado'
  end

  def facturas_compra
    flash[:error] = "Informe no disponible"
    redirect_to :action => 'listado'
  end

  def facturas_servicios
    flash[:error] = "Informe no disponible"
    redirect_to :action => 'listado'
  end

end

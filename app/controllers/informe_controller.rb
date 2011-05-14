class InformeController < ApplicationController

  def index
    flash[:mensaje] = "Listado de elementos 'Perdidos'"
    @informes = [ ["Productos Vendidos", "productos_vendidos"] ]
  end

end

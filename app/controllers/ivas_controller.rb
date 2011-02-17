class IvasController < ApplicationController

  def index
    #@ivas = Iva.all
    flash[:mensaje] = "Listado de tipos de IVA"
    redirect_to :action => :listado
  end

  def listado
    @ivas = Iva.all
  end

  def create
    @iva = Iva.new(params[:iva])

    respond_to do |format|
      if @iva.save
        flash[:mensaje] = 'Iva was successfully created.'
        redirect_to :action => "index"
      else
        flash[:error] = @iva
        redirect_to :action => "new"
      end
    end
  end

  def editar
    @iva = params[:id] ?  Iva.find(params[:id]) : nil
  end

  def modificar 
    @iva = params[:id] ?  Iva.find(params[:id]) : Iva.new
    @iva.update_attributes params[:iva]
    flash[:error] = @iva
    redirect_to :action => :listado
  end
  
  def borrar 
    @iva = Iva.find(params[:id])
    @iva.destroy
    flash[:error] = @iva
    redirect_to :action => :listado
  end

end

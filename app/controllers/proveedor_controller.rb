class ProveedorController < ApplicationController

  def index
    redirect_to :action => :listado
  end

  def listado
    flash[:mensaje] = "Listado de proveedores"
    @proveedores = Proveedor.paginate( :order => 'nombre',
			:page => (params[:format]=='xls' ? nil : params[:page]), :per_page => (params[:format_xls_count] || Configuracion.valor('PAGINADO') ))
    @formato_xls = @proveedores.total_entries
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "proveedores"
        @objetos = @proveedores
        #@subhoja = { :titulo => "nombre", :cabecera => "Productos Comprados", :objetos => "productos_comprados", :tipo => "productos_comprados" } 
        render 'comunes_xls/listado', :layout => false
      end
    end
  end

  def editar
    @proveedor = params[:id] ? Proveedor.find(params[:id]) : Proveedor.new
    render :partial => "formulario"
  end

  def modificar
    proveedor = params[:id] ? Proveedor.find(params[:id]) : Proveedor.new
    proveedor.update_attributes params[:proveedor]
    flash[:error] = proveedor 
    redirect_to :action => :listado
  end

  def borrar
    proveedor = Proveedor.find_by_id params[:id]
    proveedor.destroy
    flash[:error] = proveedor 
    redirect_to :action => :listado
  end

  # Devuelve sublistado de productos comprados al proveedor
  def productos
    proveedor = Proveedor.find_by_id(params[:id]) if params[:id]
    @lineas = proveedor.productos_comprados if proveedor
    #puts "--------------->" + @lineas.to_s
    @formato_xls = true
    respond_to do |format|
      format.xls do
        @tipo = "productos_comprados"
        @objetos = @lineas
        @xls_title = "Productos"
        @xls_head = "Productos Comprados " + proveedor.nombre
        render 'comunes_xls/listado', :layout => false
      end 
      format.html do
        render :update do |page|
          page.replace_html params[:update], :partial => "productos"
        end
      end
    end
  end

end

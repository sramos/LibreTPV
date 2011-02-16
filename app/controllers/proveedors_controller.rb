class ProveedorsController < ApplicationController
  # GET /proveedors
  # GET /proveedors.xml
  def index
    @proveedors = Proveedor.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @proveedors }
    end
  end

  # GET /proveedors/1
  # GET /proveedors/1.xml
  def show
    @proveedor = Proveedor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @proveedor }
    end
  end

  # GET /proveedors/new
  # GET /proveedors/new.xml
  def new
    @proveedor = Proveedor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @proveedor }
    end
  end

  # GET /proveedors/1/edit
  def edit
    @proveedor = Proveedor.find(params[:id])
  end

  # POST /proveedors
  # POST /proveedors.xml
  def create
    @proveedor = Proveedor.new(params[:proveedor])

    respond_to do |format|
      if @proveedor.save
        flash[:notice] = 'Proveedor was successfully created.'
        format.html { redirect_to(@proveedor) }
        format.xml  { render :xml => @proveedor, :status => :created, :location => @proveedor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @proveedor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /proveedors/1
  # PUT /proveedors/1.xml
  def update
    @proveedor = Proveedor.find(params[:id])

    respond_to do |format|
      if @proveedor.update_attributes(params[:proveedor])
        flash[:notice] = 'Proveedor was successfully updated.'
        format.html { redirect_to(@proveedor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @proveedor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /proveedors/1
  # DELETE /proveedors/1.xml
  def destroy
    @proveedor = Proveedor.find(params[:id])
    @proveedor.destroy

    respond_to do |format|
      format.html { redirect_to(proveedors_url) }
      format.xml  { head :ok }
    end
  end
end

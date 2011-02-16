class AlbaranLineasController < ApplicationController
  # GET /albaran_lineas
  # GET /albaran_lineas.xml
  def index
    @albaran_lineas = AlbaranLinea.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @albaran_lineas }
    end
  end

  # GET /albaran_lineas/1
  # GET /albaran_lineas/1.xml
  def show
    @albaran_linea = AlbaranLinea.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @albaran_linea }
    end
  end

  # GET /albaran_lineas/new
  # GET /albaran_lineas/new.xml
  def new
    @albaran_linea = AlbaranLinea.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @albaran_linea }
    end
  end

  # GET /albaran_lineas/1/edit
  def edit
    @albaran_linea = AlbaranLinea.find(params[:id])
  end

  # POST /albaran_lineas
  # POST /albaran_lineas.xml
  def create
    @albaran_linea = AlbaranLinea.new(params[:albaran_linea])

    respond_to do |format|
      if @albaran_linea.save
        flash[:notice] = 'AlbaranLinea was successfully created.'
        format.html { redirect_to(@albaran_linea) }
        format.xml  { render :xml => @albaran_linea, :status => :created, :location => @albaran_linea }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @albaran_linea.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /albaran_lineas/1
  # PUT /albaran_lineas/1.xml
  def update
    @albaran_linea = AlbaranLinea.find(params[:id])

    respond_to do |format|
      if @albaran_linea.update_attributes(params[:albaran_linea])
        flash[:notice] = 'AlbaranLinea was successfully updated.'
        format.html { redirect_to(@albaran_linea) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @albaran_linea.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /albaran_lineas/1
  # DELETE /albaran_lineas/1.xml
  def destroy
    @albaran_linea = AlbaranLinea.find(params[:id])
    @albaran_linea.destroy

    respond_to do |format|
      format.html { redirect_to(albaran_lineas_url) }
      format.xml  { head :ok }
    end
  end
end

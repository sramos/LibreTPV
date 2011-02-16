class FamiliasController < ApplicationController
  # GET /familias
  # GET /familias.xml
  def index
    @familias = Familia.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @familias }
    end
  end

  # GET /familias/1
  # GET /familias/1.xml
  def show
    @familia = Familia.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @familia }
    end
  end

  # GET /familias/new
  # GET /familias/new.xml
  def new
    @familia = Familia.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @familia }
    end
  end

  # GET /familias/1/edit
  def edit
    @familia = Familia.find(params[:id])
  end

  # POST /familias
  # POST /familias.xml
  def create
    @familia = Familia.new(params[:familia])

    respond_to do |format|
      if @familia.save
        flash[:notice] = 'Familia was successfully created.'
        format.html { redirect_to(@familia) }
        format.xml  { render :xml => @familia, :status => :created, :location => @familia }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @familia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /familias/1
  # PUT /familias/1.xml
  def update
    @familia = Familia.find(params[:id])

    respond_to do |format|
      if @familia.update_attributes(params[:familia])
        flash[:notice] = 'Familia was successfully updated.'
        format.html { redirect_to(@familia) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @familia.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /familias/1
  # DELETE /familias/1.xml
  def destroy
    @familia = Familia.find(params[:id])
    @familia.destroy

    respond_to do |format|
      format.html { redirect_to(familias_url) }
      format.xml  { head :ok }
    end
  end
end

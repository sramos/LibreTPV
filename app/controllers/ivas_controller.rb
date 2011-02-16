class IvasController < ApplicationController
  # GET /ivas
  # GET /ivas.xml
  def index
    @ivas = Iva.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ivas }
    end
  end

  # GET /ivas/1
  # GET /ivas/1.xml
  def show
    @iva = Iva.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @iva }
    end
  end

  # GET /ivas/new
  # GET /ivas/new.xml
  def new
    @iva = Iva.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @iva }
    end
  end

  # GET /ivas/1/edit
  def edit
    @iva = Iva.find(params[:id])
  end

  # POST /ivas
  # POST /ivas.xml
  def create
    @iva = Iva.new(params[:iva])

    respond_to do |format|
      if @iva.save
        flash[:notice] = 'Iva was successfully created.'
        format.html { redirect_to(@iva) }
        format.xml  { render :xml => @iva, :status => :created, :location => @iva }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @iva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ivas/1
  # PUT /ivas/1.xml
  def update
    @iva = Iva.find(params[:id])

    respond_to do |format|
      if @iva.update_attributes(params[:iva])
        flash[:notice] = 'Iva was successfully updated.'
        format.html { redirect_to(@iva) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @iva.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ivas/1
  # DELETE /ivas/1.xml
  def destroy
    @iva = Iva.find(params[:id])
    @iva.destroy

    respond_to do |format|
      format.html { redirect_to(ivas_url) }
      format.xml  { head :ok }
    end
  end
end

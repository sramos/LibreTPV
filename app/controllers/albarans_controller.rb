class AlbaransController < ApplicationController
  # GET /albarans
  # GET /albarans.xml
  def index
    @albarans = Albaran.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @albarans }
    end
  end

  # GET /albarans/1
  # GET /albarans/1.xml
  def show
    @albaran = Albaran.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @albaran }
    end
  end

  # GET /albarans/new
  # GET /albarans/new.xml
  def new
    @albaran = Albaran.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @albaran }
    end
  end

  # GET /albarans/1/edit
  def edit
    @albaran = Albaran.find(params[:id])
  end

  # POST /albarans
  # POST /albarans.xml
  def create
    @albaran = Albaran.new(params[:albaran])

    respond_to do |format|
      if @albaran.save
        flash[:notice] = 'Albaran was successfully created.'
        format.html { redirect_to(@albaran) }
        format.xml  { render :xml => @albaran, :status => :created, :location => @albaran }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @albaran.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /albarans/1
  # PUT /albarans/1.xml
  def update
    @albaran = Albaran.find(params[:id])

    respond_to do |format|
      if @albaran.update_attributes(params[:albaran])
        flash[:notice] = 'Albaran was successfully updated.'
        format.html { redirect_to(@albaran) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @albaran.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /albarans/1
  # DELETE /albarans/1.xml
  def destroy
    @albaran = Albaran.find(params[:id])
    @albaran.destroy

    respond_to do |format|
      format.html { redirect_to(albarans_url) }
      format.xml  { head :ok }
    end
  end
end

class LaborTypesController < ApplicationController
  before_filter :login_required
  layout "settings"

  def index
    @labor_types = LaborType.find(:all, :order => "name")
  end
  
  def new
    @labor_type = LaborType.new
    begin
      @qb_labor_types = QB::ItemService.all()
    rescue
      flash[:notice] = "Could not connect to Quickbooks."
      @qb_labor_types = []
    ensure
      Quickbooks.connection.close
    end
  end
  
  def create
    @labor_type = LaborType.new(params[:labor_type])
    if @labor_type.save
      flash[:notice] = "LaborType created successfully!"
      redirect_to labor_types_url
    else
      flash[:notice] = @labor_type.errors.to_s
      redirect_to new_labor_type_url
    end
  end
  
  def edit
    @labor_type = LaborType.find(params[:id])
    begin
      @qb_labor_types = QB::ItemService.all(:NameFilter => {:MatchCriterion => "StartsWith", :Name => "LABOR"})
    rescue
      flash[:notice] = "Could not connect to Quickbooks."
      @qb_labor_types = []
    ensure
      Quickbooks.connection.close
    end
  end
  
  def update
    @labor_type = LaborType.find(params[:id])
    if @labor_type.update_attributes(params[:labor_type])
      flash[:notice] = "LaborType updated successfully!"
      redirect_to labor_types_url
    else
      flash[:notice] = @labor_type.errors.to_s
      redirect_to edit_labor_type_url(@labor_type)
    end
  end
  
  def destroy
    @labor_type = LaborType.find(params[:id])
    @labor_type.destroy

    respond_to do |format|
      format.html { redirect_to(labor_types_url) }
      format.xml  { head :ok }
    end
  end
  
end
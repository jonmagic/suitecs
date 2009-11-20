class LocationsController < ApplicationController
  before_filter :login_required
  layout nil
  skip_before_filter :verify_authenticity_token, :only => ['update']
  
  def index
    @locations = Location.all
    render :json => @locations
  end
  
  def show
    @location = Location.find(params[:id])
  end
  
  def new
    @location = Location.new
  end
  
  def create
    @location = Location.new(params[:location])
    if @location.save
      flash[:notice] = "Location was created successfully!"
      redirect_to "/inventory"
    else
      flash[:notice] = "Location could not be saved..."
      redirect_to "/inventory"
    end
  end
  
  def update
    @location = Location.find(params[:id])
    if params[:type] == "add_item"
      if @location.add_item(params[:item_id], params[:quantity])
        InventoryLog.create(:user_id => current_user.id, 
                            :action => "Moved", 
                            :quantity => params[:quantity], 
                            :item_id => params[:item_id],
                            :destination => {'type' => 'location', 'id' => @location.id})
      end
      if @location.save
        render :nothing => true, :status => 200
      else
        render :nothing => true, :status => 500
      end
    elsif params[:type] == "remove_item"
      if @location.remove_item(params[:item_id], params[:quantity])
        InventoryLog.create(:user_id => current_user.id, 
                            :action => "Removed",
                            :quantity => params[:quantity],
                            :item_id => params[:item_id],
                            :source => {'type' => 'location', 'id' => @location.id})
      end
      if @location.save
        render :nothing => true, :status => 200
      else
        render :nothing => true, :status => 500
      end
    else
      if @location.update_attributes(params[:location])
        flash[:notice] = "Location updated."
        redirect_to "/inventory"
      else
        flash[:notice] = "Location was not updated"
        redirect_to "/inventory"
      end
    end
  end
  
  def destroy
    @location = Location.find(params[:id])
    if @location.destroy
      flash[:notice] = "Location was deleted successfully :-("
      redirect_to "/inventory"
    else
      flash[:notice] = "Location could not be deleted..."
      redirect_to "/inventory"
    end
  end
end
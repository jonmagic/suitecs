class InventoryController < ApplicationController
  before_filter :login_required
  
  def index
    if params[:q]
      @items = Item.all(:_keywords => /#{params[:q]}/i)
      respond_to do |format|
        format.html { render :partial => 'inventory/items', :layout => false }
        format.json
      end
    end
  end
  
  def show
    @item = Item.find(params[:id])
    render :layout => false
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end
end
class InventoryController < ApplicationController
  before_filter :login_required
  
  def index
    if params[:q]
      @items = Item.all(:_keywords => /#{params[:q]}/i)
      render :partial => 'inventory/items', :layout => false
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
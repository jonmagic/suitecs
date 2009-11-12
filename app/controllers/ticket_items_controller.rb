class TicketItemsController < ApplicationController
  before_filter :login_required
  layout nil
  
  def index
    render :nothing => true
  end
  
  def show
    @ticket_item = TicketItem.new(:item_id => Item.find_by_barcode(params[:id]).id, :ticket_id => params[:ticket_id])
  end
  
  def create
    @ticket_item = TicketItem.new(params[:ticket_item])
    if @ticket_item.update_or_save
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end
  
  def update
    
  end
  
  def destroy
    @ticket_item = TicketItem.find(params[:id])
    if @ticket_item.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end      
  end
end
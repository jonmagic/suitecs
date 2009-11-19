class TicketItemsController < ApplicationController
  before_filter :login_required
  layout nil
  
  def index
    render :nothing => true
  end
  
  def barcode
    @ticket_item = TicketItem.new(:item_id => Item.find_by_barcode(params[:id]).id, :ticket_id => params[:ticket_id])
    @locations = []
    Location.all('items.'+@ticket_item.item.id => {"$exists" => true}).each { |l| if l.items[@ticket_item.item.id][:quantity] > 0 then @locations << l end }
    render :partial => 'item_form'
  end
  
  def item_id
    @ticket_item = TicketItem.new(:item_id => Item.find(params[:id]).id, :ticket_id => params[:ticket_id])
    @locations = Location.all('items.'+@ticket_item.item.id => {"$exists" => true})
    render :partial => 'item_form'
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
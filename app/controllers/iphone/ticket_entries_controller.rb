class Iphone::TicketEntriesController < ApplicationController
  before_filter :login_required
  layout nil
  
  def new
    @ticket_entry = TicketEntry.new
    @ticket = Ticket.find(params[:ticket_id])
  end
  
  def create
    @ticket_entry = TicketEntry.new(params[:ticket_entry])
    @ticket = Ticket.find(params[:ticket_id])
    
    if @ticket_entry.save
      render :text => @ticket.id.to_s, :status => 200
    else
      render :text => "failed", :status => 500
    end
  end
  
end
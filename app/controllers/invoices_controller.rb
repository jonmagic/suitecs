class InvoicesController < ApplicationController

  def create
    ticket = Ticket.find(params[:ticket_id])
    
  end

end
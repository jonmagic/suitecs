class TicketEntriesController < ApplicationController
  before_filter :login_required
  layout nil
  
  def index
    @ticket = Ticket.find(params[:ticket_id])
    array = TicketEntry.find_all_by_ticket_id(@ticket.id) + TicketItem.find_all_by_ticket_id(@ticket.id)
    @ticket_entries = array.sort_by(&:created_at).reverse
  end
  
  def show
    @entry = TicketEntry.find(params[:id])
  end

  def new
    @ticket_entry = TicketEntry.new(:billable => true)
  end

  def create
    @ticket_entry = TicketEntry.new(params[:ticket_entry])
    @ticket = Ticket.find(@ticket_entry.ticket_id)
    
    respond_to do |format|
      if @ticket_entry.save
        flash[:notice] = 'Ticket entry was successfully created.'
        format.html { redirect_to(@ticket) }
        format.xml  { render :xml => @ticket_entry, :status => :created, :location => @ticket_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket_entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @ticket_entry = TicketEntry.find(params[:id])
  end
  
  def update
    @ticket_entry = TicketEntry.find(params[:id])

    respond_to do |format|
      if @ticket_entry.update_attributes(params[:ticket_entry])
        flash[:notice] = 'Ticket entry was successfully updated.'
        format.html { redirect_to(@ticket_entry.ticket) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ticket_entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @entry = TicketEntry.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to(ticket_entries_url) }
      format.xml  { head :ok }
    end
  end
  
end

class TicketsController < ApplicationController
  before_filter :login_required
  before_filter :load_totals, :except => [:create, :update]
  
  def index
    @tickets = Ticket.limit(params[:status], current_user, params[:scope])
    @tickets = @tickets.sort_by{|ticket| [ticket.status, ticket.id]}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tickets }
      format.json  { render :json => @tickets }
    end
  end
  
  def calendar
    start_date = Time.at(params[:start].to_i).to_date
    end_date   = Time.at(params[:end].to_i).to_date
    @tickets = Ticket.find(:all, :conditions => {:active_on => start_date..end_date})
    events = []
    @tickets.each { |ticket| events << {:id => ticket.id, :title => "#{ticket.id}: #{ticket.description[0..60]}", :start => "#{ticket.active_on.to_time.iso8601}", :allDay => true} }
    render :text => events.to_json
  end
  
  def search
    @tickets = Ticket.search(params[:q], :include => [:ticket_entries, :client])
  end

  def show
    @ticket = Ticket.find(params[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ticket }
      format.json  { render :json => @ticket }
    end
  end
  
  def new
    @ticket = Ticket.new
  end
  
  def create
    @ticket = Ticket.new(params[:ticket])
    
    respond_to do |format|
      if @ticket.save
        if params[:device_id] != nil
          @device = Device.find(params[:device_id])
          @ticket.devices << @device
          TicketEntry.create(:entry_type => "Add Device", :note => "Device (Service Tag: #{@device.service_tag}) was added to this ticket.", :billable => false, :private => true, :detail => 6, :ticket => @ticket, :creator_id => current_user.id)
        end
        flash[:notice] = 'Ticket was successfully created.'
        format.html { redirect_to(@ticket) }
        format.xml  { render :xml => @ticket, :status => :created, :location => @ticket }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @ticket = Ticket.find(params[:id])
  end
  
  def update
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      if @ticket.update_attributes(params[:ticket])
        flash[:notice] = 'Ticket was successfully updated.'
        format.html { redirect_to(@ticket) }
        format.js { render :json => @ticket.to_json(:methods => [:status, :technician_name]) }
      else
        format.html { render :action => "edit" }
        format.js { render :json => @ticket.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  protected
  
    def load_totals
      @totals = Ticket.totals(current_user)
    end

end
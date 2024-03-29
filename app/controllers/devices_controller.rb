class DevicesController < ApplicationController
  before_filter :login_required
  layout 'devices', :except => [:details]

  def index
    if params[:client_id]
      @devices = Device.find(:all, :conditions => {:client_id => params[:client_id]})
    elsif params[:q]
      @devices = Device.search(params[:q], :include => [:client])
    elsif params[:status]
      if params[:status] == "down"
        @devices = Device.find_all_in_trouble
      else
        @devices = []
      end
    else
      @devices = []
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @devices }
      format.json  { render :json => @devices.to_json() }
    end
  end
  
  def show
    @device = Device.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @device }
      format.json  { render :json => @device }
    end
  end
  
  def details
    @device = Device.find(params[:id])
    @ticket = Ticket.find(params[:ticket_id])
  end
  
  def add_to_ticket
    @ticket = Ticket.find(params[:ticket_id])
    @device = Device.find(params[:id])
    @ticket.devices << @device
    TicketEntry.create(:entry_type => "Added Existing Device", :note => "Device (Service Tag: #{@device.service_tag}) was added to this ticket.", :billable => false, :private => true, :detail => 6, :ticket => @ticket, :creator_id => current_user.id)
    redirect_to ticket_path(@ticket)
  end
  
  def remove_from_ticket
    @ticket = Ticket.find(params[:ticket_id])
    @device = Device.find(params[:id])
    @ticket.devices.delete(@device)
    TicketEntry.create(:entry_type => "Removed Device", :note => "Device (Service Tag: #{@device.service_tag}) was removed from this ticket.", :billable => false, :private => true, :detail => 6, :ticket => @ticket, :creator_id => current_user.id)
    redirect_to ticket_path(@ticket)
  end
  
  def new
    @device = Device.new
  end

  def create
    @device = Device.new(params[:device])
    
    if params[:ticket_id] != nil
      @ticket = Ticket.find(params[:ticket_id])
      @ticket.devices << @device
    end
    
    respond_to do |format|
      if @device.save
        if params[:ticket_id] != nil
          TicketEntry.create(:entry_type => "Added New Device", :note => "New Device (Service Tag: #{@device.service_tag}) was added to this ticket.", :billable => false, :private => true, :detail => 6, :ticket => @ticket, :creator_id => current_user.id)
          flash[:notice] = 'Device was successfully created.'
          format.html { redirect_to :back }
        else
          flash[:notice] = 'Device was successfully created.'
          format.html { redirect_to url_for(@device) }
          format.xml  { render :xml => @device, :status => :created, :location => @device }
        end
      else
        flash[:notice] = @device.errors.inspect
        format.html { redirect_to :back }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @device = Device.find(params[:id])
  end
  
  def update
    @device = Device.find(params[:id])

    respond_to do |format|
      if @device.update_attributes(params[:device])
        flash[:notice] = 'Device was successfully updated.'
        format.html { redirect_to(@device) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @device = Device.find(params[:id])
    @device.destroy

    respond_to do |format|
      format.html { redirect_to(devices_url) }
      format.xml  { head :ok }
    end
  end
  
  def download_sma
    @device = Device.find(params[:device_id])
    if @device.generate
      send_file RAILS_ROOT+"/lib/sma/devices/"+@device.id.to_s+"/sma_installer.exe"
    else
      flash[:notice] = "Failed to generate SuiteMonitorApp."
      redirect_to :back
    end
  end

end
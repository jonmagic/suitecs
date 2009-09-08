class Iphone::DevicesController < ApplicationController
  before_filter :login_required
  layout nil
  
  def show
    @device = Device.find(params[:id])
  end
  
  def index
    if params[:client_id]
      @devices = Device.find(:all, :conditions => {:client_id => params[:client_id]})
    elsif params[:ticket_id]
      @devices = Ticket.find(params[:ticket_id]).devices
    else
      if params[:q]
        @devices = Device.search(params[:q], :include => [:client])
      else
        @devices = []
      end
    end
  end
  
  def new
    @device = Device.new
    @client = Client.find(params[:client_id])
  end
  
  def create
    @device = Device.new(params[:device])
    
    if @device.save
      render :text => @device.id.to_s, :status => 200
    else
      render :text => @device.errors.inspect.to_s, :status => 500
    end
  end
  
  def update
    @device = Device.find(params[:id])
    
    if @device.update_attributes(params[:device])
      render :text => @device.id.to_s, :status => 200
    else
      render :text => @device.errors.inspect.to_s, :status => 500
    end
  end
  
end
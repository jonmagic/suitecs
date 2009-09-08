class Iphone::ClientsController < ApplicationController
  before_filter :login_required
  layout 'iphone', :only => "home"
  
  def home
  end
  
  def show
    @client = Client.find(params[:id])
  end
  
  def index
    if params[:q]
      @clients = Client.search(params[:q], :limit => 100, :only => [:firstname, :lastname, :name])
    else
      @clients = []
    end
  end
  
  def new
    @client = Client.new
  end
  
  def create
    @client = Client.new(params[:client])
    
    if @client.save
      render :text => @client.id.to_s, :status => 200
    else
      render :text => @client.errors.inspect.to_s, :status => 500
    end
  end
  
  def update
    params[:client][:existing_phone_attributes] ||= {}
    params[:client][:existing_email_attributes] ||= {}
    params[:client][:existing_address_attributes] ||= {}
    @client = Client.find(params[:id])
    
    if @client.update_attributes params[:client]
      render :text => @client.id.to_s, :status => 200
    else
      render :text => @client.errors.inspect.to_s, :status => 500
    end
  end
  
end
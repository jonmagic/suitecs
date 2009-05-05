class QbClientConnectorController < ApplicationController
  layout "settings"
  
  def index
    @ajax = false

    if params[:q]
      begin
        @ajax = true
        @possibles = QB::Customer.all(:MaxReturned => 5, :NameFilter => {:MatchCriterion => "Contains", :Name => "#{params[q]}"})
        @clients = []
        render :layout => false
      rescue
        @clients = []
        @possibles = []
        render :layout => false
      ensure
        Quickbooks.connection.close
      end
    else
      @clients = Client.find(:all, :conditions => {:qb_id => nil})
    end
  end
  
  def show
    @client = Client.find(params[:id])
    @client.company? ? name = @client.name : @client.lastname
    begin
      @possibles = QB::Customer.all(:MaxReturned => 5, :NameFilter => {:MatchCriterion => "Contains", :Name => "#{name}"})
    rescue
      flash[:notice] = "Could not connect to Quickbooks."
      @possibles = []
    ensure
      Quickbooks.connection.close
    end
  end
  
  def update
    @client = Client.find(params[:id])
    
    @client.qb_id = params[:client][:qb_id]
    if @client.save
      flash[:notice] = "Client qb_id has been updated!"
      redirect_to "/qb_client_connector"
    else
      flash[:error] = "epic fail"
      redirect_to :back
    end
  end
end
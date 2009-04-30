class QbClientConnectorController < ApplicationController
  layout "settings"
  
  def index
    @ajax = false

    if params[:q]
      @ajax = true
      @possibles = QB::Customer.all(:MaxReturned => 5, :NameFilter => {:MatchCriterion => "Contains", :Name => "#{params[q]}"})
      Quickbooks.connection.close
      @clients = []
      render :layout => false
    else
      @clients = Client.find(:all, :conditions => {:qb_id => nil})
    end
  end
  
  def show
    @client = Client.find(params[:id])
    @client.company? ? name = @client.name : @client.lastname
    @possibles = QB::Customer.all(:MaxReturned => 5, :NameFilter => {:MatchCriterion => "Contains", :Name => "#{name}"})
    Quickbooks.connection.close
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
class SetupController < ApplicationController

  def index
    if User.find(:all).length == 0
      @client = Client.new
    else
      redirect_to "/"
    end
  end
  
  def create
    if User.find(:all).length == 0
      @client = Client.new(params[:client])
    
      admin_role = Role.find(:first, :conditions => {:name => 'admin'})
      technician_role = Role.find(:first, :conditions => {:name => 'technician'})
    
      if @client.save
        @user = User.new(:email => @client.emails[0].address, :name => @client.fullname, :password => params[:password], :password_confirmation => params[:password_confirmation])
        if @user.save
          @user.register!
          @user.activate!
          @user.roles << admin_role
          @user.roles << technician_role
          @user.client_id = @client.id
          @user.save
        
          flash[:notice] = 'User & Client were successfully created.'
          redirect_to "/"
        else
          flash[:notice] = @user.errors
          redirect_to "/setup"
        end
      else
        flash[:notice] = @client.errors
        redirect_to "/setup"
      end
    else
      redirect_to "/"
    end
  end
end
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
          
          file = File.open(RAILS_ROOT+"/config/environments/production.rb", "a")

          if params[:mail_setup] == "sendmail"
            file.puts "\nActionMailer::Base.delivery_method = :sendmail\n\n"
            file.puts "ActionMailer::Base.sendmail_settings = {\n"
            file.puts "  :location       => '/usr/sbin/sendmail',\n"
            file.puts "  :arguments      => '-i -t'\n"
            file.puts "}"
          elsif params[:mail_setup] == "gmail"
            file.puts "\nrequire 'smtp_tls'\n\n"
            file.puts "ActionMailer::Base.smtp_settings = {\n"
            file.puts "  :address => 'smtp.gmail.com',\n"
            file.puts "  :port => '587',\n"
            file.puts "  :domain => '#{params[:local_domain]}',\n"
            file.puts "  :authentication => :plain,\n"
            file.puts "  :user_name => '#{params[:gmail_address]}',\n"
            file.puts "  :password => '#{params[:gmail_password]}'\n"
            file.puts "}"
          end
          
          file.close
        
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
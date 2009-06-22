class SettingsController < ApplicationController
  before_filter :login_required
  layout 'settings'

  def index
    @settings = Setting.find(:all)
  end
  
  def new
    @setting = Setting.new
  end
  
  def create
    @setting = Setting.new(params[:setting])
    if @setting.save
      flash[:notice] = "Setting created successfully!"
      redirect_to settings_url
    else
      flash[:notice] = @setting.errors.to_s
      redirect_to new_setting_url
    end
  end
  
  def edit
    @setting = Setting.find(params[:id])
  end
  
  def update
    @setting = Setting.find(params[:id])
    if @setting.update_attributes(params[:setting])
      flash[:notice] = "Setting updated successfully!"
      redirect_to settings_url
    else
      flash[:notice] = @setting.errors.to_s
      redirect_to edit_setting_url(@setting)
    end
  end

end
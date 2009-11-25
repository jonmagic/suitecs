class InventoryLogController < ApplicationController
  layout 'inventory'
  def index
    # options
    @user_options = [['','']] + User.find(:all).map {|u| [u.name,u.id]}
    @to_options = [['',''],['Ticket','ticket']] + Location.all.map {|u| [u.name,u.id]}
    @from_options = [['',''],['Ticket','ticket']] + Location.all.map {|u| [u.name,u.id]}
    conditions = {}
    conditions = conditions.merge(:order => 'created_at Desc', :limit => 100)
    @log_items = InventoryLog.all(conditions)
  end
  
  def search
    conditions = {}
    # filter by user
    conditions[:user_id] = params['user_id'].to_i unless params['user_id'].blank?
    # filter by action
    conditions[:action] = params['action_type'] unless params['action_type'].blank?
    # filter by inventory item
    conditions[:item_id] = params['item_id'] unless params['item_id'].blank?
    # filter by destination, can be a ticket or a location
    if params['to'] == 'ticket' && params['to_id']
      conditions['destination.type'] = 'ticket'
      conditions['destination.id'] = params['to_id'].to_i
    elsif !params['to'].blank?
      conditions['destination.type'] = 'location'
      conditions['destination.id'] = params['to']
    end
    # filter by source, can be a ticket or a location
    if params['from'] == 'ticket' && params['from_id']
      conditions['source.type'] = 'ticket'
      conditions['source.id'] = params['from_id'].to_i
    elsif !params['from'].blank?
      conditions['source.type'] = 'location'
      conditions['source.id'] = params['from']
    end
    if params['device_service_tag']
      if device = Device.find_by_service_tag(params['device_service_tag'])
        conditions[:device_id] = device.id
      end
    end
    # filter by start and end date
    # if !params['start_date'].blank? && !params['end_date'].blank?
    #   conditions[:created_at] = params['start_date'].to_time..params['end_date'].to_time
    # elsif !params['start_date'].blank? && params['end_date'].blank?
    #   conditions[:created_at] = params['start_date'].to_time..Time.now
    # elsif params['start_date'].blank? && !params['end_date'].blank?
    #   conditions[:created_at] = 1000.days.ago..params['end_date'].to_time
    # end
    # merge conditons and render the partial
    conditions = conditions.merge(:order => 'created_at Desc', :limit => 100)
    # raise conditions.inspect
    @log_items = InventoryLog.all(conditions)
    render :partial => 'search_results'
  end
end
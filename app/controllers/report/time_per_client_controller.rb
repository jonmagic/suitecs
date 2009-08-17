require 'lib/last_day_next_day'

class Report::TimePerClientController < ApplicationController
  before_filter :login_required
  layout 'reports'
  
  def index
    # set my start and end dates, either taken from the form or generated on the fly
    first_day = LastDayNextDay.last(Setting.find(:first, :conditions => {:key => "first_day_of_payroll"}).value)
    last_day = LastDayNextDay.next(Setting.find(:first, :conditions => {:key => "last_day_of_payroll"}).value)
    if params[:start_date] && params[:end_date]
      true
    elsif !params[:start_date] && !params[:end_date]
      LastDayNextDay.last(Setting.find(:first, :conditions => {:key => "first_day_of_payroll"}).value).cwday == Date.today.cwday ? params[:start_date] = Date.today.strftime("%Y-%m-%d") : params[:start_date] = first_day.to_s
      params[:end_date] = last_day.to_s
    elsif params[:start_date] && !params[:end_date]
      Date.today.cwday != last_day.cwday ? params[:end_date] = last_day.to_s : params[:end_date] = Date.today
    elsif params[:end_date] && !params[:start_date]
      Date.today.cwday != first_day.cwday ? params[:start_date] = first_day.to_s : params[:start_date] = Date.today
    end
    start_date = params[:start_date] + " 00:00:00"
    end_date = params[:end_date] + " 23:59:59"
    
    # find all ticket entries in the date range
    entries = TicketEntry.find(:all, :conditions => {:created_at.gte => start_date, :created_at.lte => end_date})
    
    # what are all my labor types, set it global so the view can see it
    @labor_types = LaborType.find(:all)
    
    # find the techs in these tickets
    client_ids = []
    entries.each do |entry|
      if !entry.time.blank? || !entry.drive_time.blank?
        client_ids << entry.ticket.client_id
      end
    end
    # create them when requested
    clients = Hash.new {|h,k| h[k] = { "Client" => Client.find(k).fullname }}
    # set all labor types for each tech to 0.0
    client_ids.uniq.each do |c|
      @labor_types.each do |lt|
        clients[c][lt.name] = 0.0
      end
      clients[c]["Billable"] = 0.0
      clients[c]["Non-Billable"] = 0.0
    end
    
    # build my header
    @header = []
    @header << "Client"
    @labor_types.each do |lt|
      @header << lt.name
    end
    @header << "Billable"
    @header << "Non-Billable"
    
    # iterate thru the entries and add time to the counters
    entries.each do |entry|
      @labor_types.each do |lt|
        if entry.labor_type == lt
          clients[entry.ticket.client_id][lt.name] += entry.time unless entry.time.blank?
        end
      end
      clients[entry.ticket.client_id]["Drive Time"] += entry.drive_time unless entry.drive_time.blank?
      if entry.billable?
        clients[entry.ticket.client_id]["Billable"] += entry.time unless entry.time.blank?
        clients[entry.ticket.client_id]["Billable"] += entry.drive_time unless entry.drive_time.blank?
      else
        clients[entry.ticket.client_id]["Non-Billable"] += entry.time unless entry.time.blank?
        clients[entry.ticket.client_id]["Non-Billable"] += entry.drive_time unless entry.drive_time.blank?
      end
    end
    
    # return these values to the view
    @clients = clients.values
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end
  
end
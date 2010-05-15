require 'lib/last_day_next_day'

class Report::TicketDetailController < ApplicationController
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
  
    # getting/setting technician_id
    if params[:technician_id]
      @selected = params[:technician_id]
    else
      @selected = 2
    end
  
    # find all ticket entries in the date range
    all_entries = TicketEntry.find(:all) do
      all do
        created_at > start_date.to_time + 5.hours
        created_at < end_date.to_time + 5.hours
        creator_id == params[:technician_id]
      end
    end
  
    # what are all my labor types, set it global so the view can see it
    @labor_types = LaborType.find(:all)
    
    entries = []
    all_entries.each do |entry|
      entries << entry unless entry.time.blank? && entry.drive_time.blank?
    end
    ticket_ids = entries.collect { |e| e.ticket_id }
    
    # create them when requested
    tickets = Hash.new {|h,k| h[k] = { "Ticket" => k.to_s }}
    # set all labor types for each tech to 0.0
    ticket_ids.uniq.each do |t|
      @labor_types.each do |lt|
        tickets[t][lt.name] = 0.0
      end
      tickets[t]["Billable"] = 0.0
      tickets[t]["Non-Billable"] = 0.0
      tickets[t]["Invoiced"] = ""
    end

    # build my header
    @header = []
    @header << "Ticket"
    @labor_types.each do |lt|
      @header << lt.name
    end
    @header << "Billable"
    @header << "Non-Billable"
    @header << "Invoiced"
    
    # iterate thru the entries and add time to the counters
    entries.each do |entry|
      @labor_types.each do |lt|
        if entry.labor_type == lt
          tickets[entry.ticket_id][lt.name] += entry.time unless entry.time.blank?
        end
      end
      tickets[entry.ticket_id]["Drive Time"] += entry.drive_time unless entry.drive_time.blank?
      if entry.billable?
        tickets[entry.ticket_id]["Billable"] += entry.time unless entry.time.blank?
        tickets[entry.ticket_id]["Billable"] += entry.drive_time unless entry.drive_time.blank?
      else
        tickets[entry.ticket_id]["Non-Billable"] += entry.time unless entry.time.blank?
        tickets[entry.ticket_id]["Non-Billable"] += entry.drive_time unless entry.drive_time.blank?
      end
      if tickets[entry.ticket_id]["Invoiced"] == ""
        tickets[entry.ticket_id]["Invoiced"] = entry.ticket.invoiced ? "Yes" : "No"
      end
    end
    
    # return these values to the view
    @technicians = User.all
    @tickets = tickets.values
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    Rails.logger.info tickets.values.to_yaml
  end
end
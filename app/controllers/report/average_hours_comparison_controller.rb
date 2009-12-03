require 'lib/last_day_next_day'

class Report::AverageHoursComparisonController < ApplicationController
  before_filter :login_required
  layout 'reports'
  
  def index
    # set my start and end dates, either taken from the form or generated on the fly
    first_day = LastDayNextDay.last(Setting.find(:first, :conditions => {:key => "first_day_of_payroll"}).value)
    if params[:start_date] && params[:end_date]
      true
    elsif !params[:start_date] && !params[:end_date]
      LastDayNextDay.last(Setting.find(:first, :conditions => {:key => "first_day_of_payroll"}).value).cwday == Date.today.cwday ? params[:start_date] = Date.today.strftime("%Y-%m-%d") : params[:start_date] = first_day.to_s
      params[:end_date] = Date.today.strftime("%Y-%m-%d")
    elsif params[:start_date] && !params[:end_date]
      params[:end_date] = Date.today.strftime("%Y-%m-%d")
    elsif params[:end_date] && !params[:start_date]
      Date.today.cwday != first_day.cwday ? params[:start_date] = first_day.to_s : params[:start_date] = Date.today.strftime("%Y-%m-%d")
    end
    start_date = params[:start_date] + " 00:00:00"
    end_date = params[:end_date] + " 23:59:59"
    
    # set my default on billable, non-billable
    !params[:scope] ? scope = "Billable" : scope = params[:scope]
    
    # find all ticket entries in the date range
    entries = TicketEntry.find(:all) do
      all do
        created_at > start_date
        created_at < end_date
      end
    end
    
    # setup my time spans
    time_span = (end_date.to_time + 1.second) - start_date.to_time
    time_spans = []
    time_spans << "Hourly"
    if time_span >= 1.day then time_spans << "Daily" end
    if time_span >= 7.days then time_spans << "Weekly" end
    if time_span >= 29.days then time_spans << "Monthly" end
    if time_span >= 364.days then time_spans << "Yearly" end
    
    # find the techs in these tickets
    technician_ids = []
    entries.each do |entry|
      technician_ids << entry.creator_id
    end
    # time to do the actual report magic
    technicians = Hash.new {|h,k| h[k] = { "Technician" => User.find(k).name }}
    # set all time spans for each tech to 0.0
    technician_ids.uniq.each do |t|
      time_spans.each do |ts|
        technicians[t][ts] = 0.0
      end
      technicians[t]["total"] = 0.0
    end

    # build my header    
    @header = []
    @header << "Technician"
    time_spans.each do |ts|
      @header << ts
    end
    
    # build totals
    @totals = {}
    time_spans.each { |ts| @totals[ts] = 0.0 }
    
    # add all my billable time in there
    entries.each do |entry|
      if scope == "Billable" && entry.billable 
        technicians[entry.creator_id]["total"] += entry.time unless entry.time.blank?
        technicians[entry.creator_id]["total"] += entry.drive_time unless entry.drive_time.blank?
      elsif scope == "Non-Billable" && !entry.billable
        technicians[entry.creator_id]["total"] += entry.time unless entry.time.blank?
        technicians[entry.creator_id]["total"] += entry.drive_time unless entry.drive_time.blank?
      elsif scope == "All Time"
        technicians[entry.creator_id]["total"] += entry.time unless entry.time.blank?
        technicians[entry.creator_id]["total"] += entry.drive_time unless entry.drive_time.blank?
      end
    end
    
    technicians.each do |id, values|
      hours = (values["total"]/60)
      hours_in_time_span = time_span.to_f/60/60
      time_spans.each do |ts|
        if ts == "Hourly"   then values["Hourly"]   = (hours/hours_in_time_span).to_four_decimal_places end
        if ts == "Daily"    then values["Daily"]    = (hours/(hours_in_time_span/24)).to_two_decimal_places end
        if ts == "Weekly"   then values["Weekly"]   = (hours/(hours_in_time_span/168)).to_two_decimal_places end
        if ts == "Monthly"  then values["Monthly"]  = (hours/(hours_in_time_span/720)).to_two_decimal_places end
        if ts == "Yearly"   then values["Yearly"]   = (hours/(hours_in_time_span/8760)).to_two_decimal_places end
      end
    end
    
    # final vars to throw into the view
    @technicians = technicians.values
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    
  end
  
end

class Float
  def to_two_decimal_places
    ((self*100).round).to_f/100
  end
  def to_four_decimal_places
    ((self*10000).round).to_f/10000
  end
end
require 'lib/last_day_next_day'

class Report::TimeSheetController < ApplicationController
  before_filter :login_required
  layout 'reports'
  
  def index
    # set my start and end dates, either taken from the form or generated on the fly
    last_saturday = "#{LastDayNextDay.last('saturday')}"
    next_friday = "#{LastDayNextDay.next('friday')}"
    if params[:start_date] && params[:end_date]
      true
    elsif !params[:start_date] && !params[:end_date]
      params[:start_date] = last_saturday
      params[:end_date] = next_friday
    elsif params[:start_date]
      Date.today.cwday != next_friday.cwday ? params[:end_date] = next_friday : Date.today
    elsif params[:end_date]
      Date.today.cwday != last_saturday.cwday ? params[:start_date] = last_saturday : Date.today
    end
    start_date = params[:start_date] + " 00:00:00"
    end_date = params[:end_date] + " 23:59:59"
    
    # find all ticket entries in the date range
    entries = TicketEntry.find(:all, :conditions => {:created_at.gte => start_date, :created_at.lte => end_date})
    
    # what are all my labor types, set it global so the view can see it
    @labor_types = LaborType.find(:all)
    
    # find the techs in these tickets
    technician_ids = []
    entries.each do |entry|
      technician_ids << entry.creator_id
    end
    # create them when requested
    technicians = Hash.new {|h,k| h[k] = { "Technician" => User.find(k).name }}
    # set all labor types for each tech to 0.0
    technician_ids.dups.each do |t|  
      @labor_types.each do |lt|
        technicians[t][lt.name] = 0.0
      end
      technicians[t]["Billable"] = 0.0
      technicians[t]["Non-Billable"] = 0.0
    end
    
    # build my header
    @header = []
    @header << "Technician"
    @labor_types.each do |lt|
      @header << lt.name
    end
    @header << "Billable"
    @header << "Non-Billable"
    
    # iterate thru the entries and add time to the counters
    entries.each do |entry|
      @labor_types.each do |lt|
        if entry.labor_type == lt
          technicians[entry.creator_id][lt.name] += entry.time unless entry.time.blank?
        end
      end
      technicians[entry.creator_id]["Drive Time"] += entry.drive_time unless entry.drive_time.blank?
      if entry.billable?
        technicians[entry.creator_id]["Billable"] += entry.time unless entry.time.blank?
        technicians[entry.creator_id]["Billable"] += entry.drive_time unless entry.drive_time.blank?
      else
        technicians[entry.creator_id]["Non-Billable"] += entry.time unless entry.time.blank?
        technicians[entry.creator_id]["Non-Billable"] += entry.drive_time unless entry.drive_time.blank?
      end
    end
    
    # return these values to the view
    @technicians = technicians.values
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end
  
end

module Enumerable
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end
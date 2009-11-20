class Ticket < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  has_many :ticket_entries
  # has_many :ticket_items
  has_and_belongs_to_many :devices
  has_many :checklists
  has_many :things, :as => :attached, :dependent => :destroy
  
  validates_presence_of :client_id
  validates_presence_of :creator_id
  validates_presence_of :user_id
  validates_presence_of :description
  
  before_create :notify_tech
  after_create :add_created_note
  before_update :add_status_change_note, :notify_tech
  
  attr_accessor :ticket_item_data
  before_save :save_ticket_item_data
  
  def save_ticket_item_data
    return if ticket_item_data.blank?
    ticket_item_data.each do |item|
      ticket_item = TicketItem.new(item.merge(:ticket_id => id))
      if ticket_item.update_or_save
        InventoryLog.create(:user_id => ticket_item.creator_id, 
                            :action => "Added", 
                            :quantity => 1, 
                            :item_id => ticket_item.item_id, 
                            :source => {'type' => 'location', 'id' => ticket_item.location},
                            :destination => {'type' => 'ticket', 'id' => ticket_item.ticket_id})
      end
    end
  end
    
  def add_created_note
    TicketEntry.create(:entry_type => "State change", :note => "Ticket created.", :billable => false, :private => true, :detail => 6, :ticket => self, :creator_id => self.creator_id)
  end
  
  def add_status_change_note
    before = Ticket.find(self.id)
    if self.status != before.status
      TicketEntry.create(:entry_type => "State change", :note => "Status changed to #{self.status}", :billable => false, :private => true, :detail => 6, :ticket => self, :creator_id => self.creator_id)
    end
  end
  
  def notify_tech
    subject = "Ticket# #{self.id} needs your attention"
    message = "#{User.find(self.creator_id).name} created or updated this ticket for you: #{APP_CONFIG[:site_url]}/tickets/#{self.id}\n\n#{self.description}"
    
    if self.new_record? && self.creator_id != self.user_id
      NotificationMailer.deliver_ticket_updated(subject, message, self.technician)
    elsif self.id
      before = Ticket.find(self.id)
      if self.user_id != before.user_id && !self.status.has("on")
        NotificationMailer.deliver_ticket_updated(subject, message, self.technician)
      end
    end
  end
  
  def status
    if self.archived_on != nil
      return "Archived on "+self.archived_on.strftime("%m/%d/%Y")
    elsif self.completed_on != nil
      return "Completed on "+self.completed_on.strftime("%m/%d/%Y")
    elsif self.active_on != nil && self.active_on > Date.today
      return "Scheduled for "+self.active_on.strftime("%m/%d/%Y")
    else
      return "Open"
    end
  end
  
  def technician
    User.find(self.user_id)
  end
  
  def owner
    Client.find(self.client_id)
  end
  
  def self.limit(status, user, scope)
    if scope == nil
      scope = user.id
    end
    future = Date.today + 100.years
    past = Date.today - 100.years
    if status == nil || status == "open"
      conditions = {:archived_on => nil, :active_on => past..Date.today, :completed_on => nil}
    elsif status == "scheduled"
      conditions = {:archived_on => nil, :active_on => Date.tomorrow..future, :completed_on => nil}
    elsif status == "completed"
      conditions = {:archived_on => nil, :completed_on => past..future}
    elsif status == "archived"
      conditions = {:archived_on => past..future}
    elsif status == "all"
      conditions = {:archived_on => nil}
    end
    if scope != "all" then conditions[:user_id] = User.find(scope) end
    self.find(:all, :conditions => conditions)
  end
  
  def limit(scope)
    new_array = ()
    self.each do |ticket|
      if ticket.user_id == scope

      end
    end
    return self
  end
  
  def billable_time
    billable_time = 0
    self.ticket_entries.each do |entry|
      if entry.billable
        if !entry.time.blank? then billable_time += entry.time end
        if !entry.drive_time.blank? then billable_time += entry.drive_time end
      end
    end
    return billable_time
  end
  
  def non_billable_time
    non_billable_time = 0
    self.ticket_entries.each do |entry|
      if !entry.billable
        if !entry.time.blank? then non_billable_time += entry.time end
        if !entry.drive_time.blank? then non_billable_time += entry.drive_time end
      end
    end
    return non_billable_time
  end
  
  def self.totals(user)
    future = Date.today + 100.years
    past = Date.today - 100.years
    totals = {}
    open = {:archived_on => nil, :active_on => past..Date.today, :completed_on => nil, :user_id => user.id}
    scheduled = {:archived_on => nil, :active_on => Date.tomorrow..future, :completed_on => nil, :user_id => user.id}
    completed = {:archived_on => nil, :completed_on => past..future, :user_id => user.id}
    all = {:archived_on => nil}
    totals[:open] = (self.find(:all, :conditions => open)).length > 0 ? (self.find(:all, :conditions => open)).length : ""
    totals[:scheduled] = (self.find(:all, :conditions => scheduled)).length
    totals[:completed] = (self.find(:all, :conditions => completed)).length
    totals[:all] = (self.find(:all, :conditions => all)).length
    return totals
  end
  
  def checklists_complete?
    checklists = []
    checklists.concat(self.checklists)
    checklists.concat(self.devices.collect{|device| device.checklists}.flatten)
    complete = 0
    checklists.each do |checklist|
      checklist.complete? ? complete += 0 : complete += 1
    end
    complete == 0
  end
  
end

class String
  def has(word)
    self =~ /#{word}/ ? true : false
  end
end
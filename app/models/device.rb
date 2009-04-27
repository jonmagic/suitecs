class Device < ActiveRecord::Base
  belongs_to :client
  belongs_to :device_type
  has_and_belongs_to_many :tickets
  has_many :checklists, :dependent => :destroy
  has_many :things, :as => :attached, :dependent => :destroy
  
  validates_uniqueness_of :service_tag
  validates_presence_of :client_id, :device_type_id
  
  before_create :create_service_tag
  after_create :create_checklists
  
  def create_service_tag
    if self.service_tag.blank?
      recent_device = Device.find(:first, :order => 'created_at DESC', :conditions => {:created_at.gt => Time.now.beginning_of_day+5.hours, :created_at.lt => Time.now.end_of_day+5.hours, :device_type_id => self.device_type_id})
      device_type = DeviceType.find(self.device_type_id)
      if recent_device != nil
        service_tag_parts= recent_device.service_tag.split("-")
        if recent_device.created_at < Date.today
          new_machine_number = 1
        else
          new_machine_number = service_tag_parts[-1].to_i + 1
        end
        self.service_tag = "#{device_type.identifier}-#{Time.now.strftime("%m%d%y")}-#{new_machine_number}"
      else
        self.service_tag = "#{device_type.identifier}-#{Time.now.strftime("%m%d%y")}-1"
      end
    end
  end
  
  def create_checklists
    checklists = self.device_type.checklist_templates
    if checklists != nil
      checklists.each do |list|
        Checklist.create(:checklist_template => list, :name => list.name, :device => self, :ticket_id => nil)
      end
    end
  end
  
  def client_name
    client = self.client
    return client.fullname
  end
  
  def ticket_id=(ticket_id)
    return ticket_id
  end
  
  def to_json(options={})
    super(options.merge(:methods => :client_name))
  end
  
  def identifier
    if !self.name.blank?
      return self.name
    else
      return self.service_tag
    end
  end
  
  def self.find_all_in_trouble
    all_devices = Device.find(:all)
    devices_in_trouble = []
    all_devices.each do |device|
      !device.healthy? ? devices_in_trouble << device : false
    end
    return devices_in_trouble
  end
  
end

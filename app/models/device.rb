require_dependency "search"

class Device < ActiveRecord::Base
  belongs_to :client
  belongs_to :device_type
  has_and_belongs_to_many :tickets
  has_many :checklists, :dependent => :destroy
  
  validates_uniqueness_of :service_tag
  
  before_create :create_service_tag
  after_create :create_checklists
  
  def create_service_tag
    if self.service_tag == ""
      recent_device = Device.find(:first, :order => 'created_at DESC')
      device_type = DeviceType.find(self.device_type_id)
      if recent_device != nil
        service_tag_parts= recent_device.service_tag.split("-")
        if recent_device.created_at < Date.today
          new_machine_number = 1
        else
          new_machine_number = service_tag_parts[-1].to_i + 1
        end
        self.service_tag = "#{device_type.identifier}-#{Time.now.strftime("%m%d%Y")}-#{new_machine_number}"
      else
        self.service_tag = "#{device_type.identifier}-#{Time.now.strftime("%m%d%Y")}-1"
      end
    end
  end
  
  def create_checklists
    checklists = self.device_type.checklist_templates
    if checklists != nil
      checklists.each do |list|
        Checklist.create(:checklist_template => list, :name => list.name, :device => self)
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
  
end

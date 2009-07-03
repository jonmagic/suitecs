class DeviceType < ActiveRecord::Base
  has_many :devices
  has_and_belongs_to_many :checklist_templates
  
  validates_presence_of :identifier, :description
  validates_uniqueness_of :identifier
  validates_length_of :identifier, :is => 3
  
end

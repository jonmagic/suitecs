class LaborType < ActiveRecord::Base
  has_many :ticket_entries
  
  # Its stupid to make this this way, but oh well FIX THIS!!!
  def self.drive_time
    LaborType.find(:first, :conditions => {:name => "Drive Time"})
  end
  
  def self.warranty
    LaborType.find(:first, :conditions => {:name => "Warranty"})
  end
  
end
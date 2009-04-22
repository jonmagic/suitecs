class LaborType < ActiveRecord::Base
  has_many :ticket_entries
  
  def qb_lookup
    if qb_labor_type = QB::ItemService.first(:ListID => [self.qb_id])
      Quickbooks.connection.close
      return qb_labor_type
    else
      Quickbooks.connection.close
      return false
    end
  end
  
  # Its stupid to make this this way, but oh well FIX THIS!!!
  def self.drive_time
    LaborType.find(:first, :conditions => {:name => "Drive Time"})
  end
  
  def self.warranty
    LaborType.find(:first, :conditions => {:name => "Warranty"})
  end
  
end
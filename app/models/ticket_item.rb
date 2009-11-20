class TicketItem
  include MongoMapper::Document

  key :ticket_id, Integer, :require => true
  key :item_id, ObjectId, :require => true
  key :quantity, Integer, :require => true, :default => 1
  key :serial_number, String
  key :creator_id, :require => true
  key :created_at, Time, :require => true
  key :updated_at, Time

  belongs_to :item
  belongs_to :ticket

  before_create :set_created_at
  before_update :set_updated_at

  def set_created_at
    self.created_at = Time.now
    set_updated_at
  end

  def set_updated_at
    self.updated_at = Time.now
  end

  def update_or_save
    if item = TicketItem.first(:ticket_id => self.ticket_id, :item_id => self.item_id)
      if serial_number.blank?
        new_quantity = item.quantity + self.quantity
        item.quantity = new_quantity
        if item.save
          Location.find(location).remove_item(self.item.id, 1).save unless location.blank?
          return true
        else
          return false
        end
      end
    else
      valid?
      if save
        Location.find(location).remove_item(self.item.id, 1).save unless location.blank?
        return true
      else
        return false
      end
    end
  end

  def creator
    User.find(self.creator_id)
  end
  
end
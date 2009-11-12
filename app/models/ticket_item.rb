class TicketItem
  include MongoMapper::Document

  key :ticket_id, Integer, :require => true
  key :item_id, String, :require => true
  key :quantity, :require => true
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
  end

  def set_updated_at
    self.updated_at = Time.now
  end

  def update_or_save
    if TicketItem.first(:ticket_id => self.ticket_id, :item_id => self.item_id) && self.serial_number == nil
      item = TicketItem.first(:ticket_id => self.ticket_id, :item_id => self.item_id)
      new_quantity = item.quantity.to_i + self.quantity.to_i
      item.update_attributes(:quantity => new_quantity)
    else
      self.save
    end
  end

  def creator
    User.find(self.creator_id)
  end
  
end
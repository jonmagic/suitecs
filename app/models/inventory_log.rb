class InventoryLog
  include MongoMapper::Document

  key :user_id, Integer, :require => true
  key :action, String, :require => true
  key :quantity, Integer
  key :item_id, ObjectId, :require => true
  key :source, Hash
  key :destination, Hash
  key :created_at, Time, :require => true
  
  belongs_to :user
  belongs_to :item
  
  # InventoryLog.create(:user_id => ticket_item.creator_id, 
  #                     :action => "Added", 
  #                     :quantity => 1, 
  #                     :item_id => ticket_item.item_id, 
  #                     :source => {'type' => 'location', 'id' => ticket_item.location},
  #                     :destination => {'type' => 'ticket', 'id' => ticket_item.ticket_id})
  
  # "jonmagic     moved     1           cable         from store      to car"
  # "#{user.name} #{action} #{quantity} #{item.name}  from #{source}  to #{destination}"
  
  before_create :set_created_at

  def set_created_at
    self.created_at = Time.now
  end

end
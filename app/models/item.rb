class Item
  include MongoMapper::Document
  
  key :qb_id, String, :require => true, :unique => true
  key :name, String
  key :description, String
  key :cost, Float
  key :retail, Float  
  key :barcode, String, :unique => true
  key :quantity, Integer
  key :_keywords, Array
  key :requires_serialnumber, Boolean
  
  has_many :ticket_items

  before_create :build_keywords
  before_update :build_keywords
  
  def build_keywords
    keywords = []
    keywords << self.qb_id
    self.name.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } }
    self.description.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } } unless self.description == nil
    self._keywords = keywords.uniq
    self._keywords << self.barcode
  end
  
  def self.sync_inventory_with_qb
    items = QB::ItemInventory.all
    items.each do |item|
      if Item.create(
                    :qb_id         => item["ListID"],
                    :name          => item["FullName"],
                    :description   => item["PurchaseDesc"],
                    :cost          => item["PurchaseCost"],
                    :retail        => item["SalesPrice"],
                    :quantity      => item["QuantityOnHand"])
      else
        Item.find_by_qb_id(item["ListID"]).update_attributes(
                    :qb_id         => item["ListID"],
                    :name          => item["FullName"],
                    :description   => item["PurchaseDesc"],
                    :cost          => item["PurchaseCost"],
                    :retail        => item["SalesPrice"],
                    :quantity      => item["QuantityOnHand"])
      end
    end
  end
  
  def locations
    # return array of locations
    return Location.all('item_ids' => self.id)
  end

end
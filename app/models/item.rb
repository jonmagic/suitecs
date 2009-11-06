class Item
  include MongoMapper::Document
  
  key :qb_id, String, :require => true, :unique => true
  key :name, String
  key :description, String
  key :cost, Float
  key :retail, Float  
  key :barcode, String
  key :_keywords, Array

  before_create :build_keywords
  
  def build_keywords
    keywords = []
    keywords << self.qb_id
    self.name.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } }
    self.description.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } } unless self.description == nil
    self._keywords = keywords.uniq
  end
  
  def self.sync_inventory_with_qb
    items = QB::ItemInventory.all
    items.each do |item|
      if Item.create(
                    :qb_id         => item["ListID"],
                    :name          => item["FullName"],
                    :description   => item["PurchaseDesc"],
                    :cost          => item["PurchaseCost"],
                    :retail        => item["SalesPrice"])
      else
        Item.find_by_qb_id(item["ListID"]).update_attributes(
                    :qb_id         => item["ListID"],
                    :name          => item["FullName"],
                    :description   => item["PurchaseDesc"],
                    :cost          => item["PurchaseCost"],
                    :retail        => item["SalesPrice"])
      end
    end
  end

end
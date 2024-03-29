class Item
  include MongoMapper::Document
  
  key :qb_id, String, :require => true, :unique => true
  key :name, String
  key :description, String
  key :cost, Float
  key :retail, Float  
  key :barcode, String
  key :quantity, Integer
  key :active, Boolean
  key :_keywords, Array
  key :requires_serialnumber, Boolean
  
  validates_uniqueness_of :barcode, :allow_blank => true
  
  has_many :ticket_items

  before_create :build_keywords
  before_update :build_keywords
  
  def build_keywords
    keywords = []
    keywords << self.qb_id
    self.name.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } }
    self.description.downcase.sub(',','').split(":").each { |k| k.split(" ").each { |k2| keywords << k2 } } unless self.description == nil
    self._keywords = keywords.uniq
    self._keywords << self.barcode unless self.barcode.blank?
  end
  
  def self.sync_inventory_with_qb
    items = QB::ItemInventory.all("ActiveStatus" => "All")
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    updated = 0
    created = 0
    items.each do |item|
      description = ic.iconv(item["SalesDesc"] + ' ')[0..-2] unless item["SalesDesc"].blank?
      active = item["IsActive"].to_s == "true" ? true : false
      if i = Item.find_by_qb_id(item["ListID"].to_s)
        if i.update_attributes(
                  :name          => ic.iconv(item["FullName"] + ' ')[0..-2],
                  :description   => description,
                  :cost          => item["PurchaseCost"],
                  :retail        => item["SalesPrice"],
                  :quantity      => item["QuantityOnHand"],
                  :active        => active)
          updated += 1
        end
      else
        if Item.create(
                      :qb_id         => item["ListID"],
                      :name          => ic.iconv(item["FullName"] + ' ')[0..-2],
                      :description   => description,
                      :cost          => item["PurchaseCost"],
                      :retail        => item["SalesPrice"],
                      :quantity      => item["QuantityOnHand"],
                      :active        => active)
          created += 1
        end
      end
    end
    puts "Updated: #{updated} Created: #{created}"
  end
  
  def locations
    # return array of locations
    return Location.all('item_ids' => self.id)
  end

end
class Location
  include MongoMapper::Document

  key :name, String, :required => true, :unique => true
  key :items, Hash
  
  def add_item(id, quantity)
    if self.items[id]
      self.items[id]['quantity'] += quantity
    else
      self.items[id] = {'quantity' => quantity}
    end
  end
  
  def remove_item(id, quantity)
    if self.items[id]
      bq = self.items[id]['quantity']
      self.items[id]['quantity'] = bq.to_i - quantity.to_i
    end
  end

end
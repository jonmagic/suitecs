class Location
  include MongoMapper::Document

  key :name, String, :required => true, :unique => true
  key :items, Hash
  
  def add_item(id, quantity)
    if self.items[id]
      self.items[id]['quantity'] += quantity.to_i
    else
      self.items[id] = {'quantity' => quantity.to_i}
    end
    return self
  end
  
  def remove_item(id, quantity)
    if self.items[id]
      bq = self.items[id]['quantity']
      self.items[id]['quantity'] = bq.to_i - quantity.to_i unless bq.to_i - quantity.to_i < 0
    end
    return self
  end
  
end
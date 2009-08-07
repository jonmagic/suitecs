class TicketEntry < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :labor_type
  
  # default_scope :order => "created_at DESC"
  
  def creator
    creator = User.find(self.creator_id)
  end
  
  def initials
    client = Client.find(self.creator.client_id)
    initials = client.firstname[0,1]+client.lastname[0,1]
  end  

end
class TicketEntry < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :labor_type
  
  def creator
    creator = User.find(self.creator_id)
  end

end
class TicketEntry < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :labor_type
  
  # default_scope :order => "created_at DESC"
  after_create :touch_ticket
  after_update :touch_ticket
  
  def creator
    User.find(self.creator_id)
  end
  
  def initials
    client = Client.find(self.creator.client_id)
    initials = client.firstname[0,1]+client.lastname[0,1]
  end

  def touch_ticket
    if self.creator.id != self.ticket.user_id
      subject = "Ticket# #{self.ticket.id} needs your attention"
      message = "#{APP_CONFIG[:site_url]}/tickets/#{self.ticket.id}"
      NotificationMailer.deliver_ticket_updated(subject, message, self.ticket.technician)
    end
  end

end
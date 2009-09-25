class TicketEntry < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :labor_type
  
  # default_scope :order => "created_at DESC"
  after_create :notify_tech
  after_update :notify_tech
  
  def creator
    User.find(self.creator_id)
  end
  
  def initials
    client = Client.find(self.creator.client_id)
    initials = client.firstname[0,1]+client.lastname[0,1]
  end

  def notify_tech
    if self.creator_id != self.ticket.user_id && !self.ticket.status.has("on")
      subject = "Ticket# #{self.ticket.id} needs your attention"
      message = "#{self.creator.name} updated or added a note to #{APP_CONFIG[:site_url]}/tickets/#{self.ticket.id}\n\n#{self.note}"
      NotificationMailer.deliver_ticket_updated(subject, message, self.ticket.technician)
    end
  end

end
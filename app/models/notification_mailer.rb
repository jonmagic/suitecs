class NotificationMailer < ActionMailer::Base
  
  def notification(subject, message, schedule_id)
    schedule = Schedule.find(schedule_id)
    technician = Client.find(schedule.user.client_id)
    email = Email.find(:first, :conditions => {:client_id => technician.id})
    @recipients = "#{email.address}"
    @from = APP_CONFIG[:admin_email]
    @subject = "#{subject}"
    @sent_on = Time.now
    @body[:message] = message
  end
  
  def ticket_updated(subject, message, email)
    @recipients = "#{email}"
    @from = "tickets@suite.sabretechllc.com"
    @subject = "#{subject}"
    @sent_on = Time.now
    @body[:message] = message
  end
  
  def attention(ticket_id, invoice_ref_number)
    ticket  = Ticket.find(ticket_id)
    @recipients = "sabretechllc@gmail.com"
    @from = APP_CONFIG[:admin_email]
    @subject = "Invoice ##{invoice_ref_number} needs attention."
    @sent_on = Time.now
    message = ""
    message << "Ticket ##{ticket.id}\n"
    message << "Description: #{ticket.description}\n\n"
    ticket.ticket_entries.each do |te|
      message << "Note by #{te.creator.name} on #{te.created_at.strftime('%m-%d-%y')}\n"
      message << "Note: #{te.note}\n"
      message << "Parts: #{te.parts}\n\n"
    end
    @body[:message] = message
  end

end
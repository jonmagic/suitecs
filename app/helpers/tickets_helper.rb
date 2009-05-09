module TicketsHelper
  def totals_helper(status)
    if @totals[status].to_i > 0
      return "<span class='totals'>#{@totals[status]}</span>"
    end
  end
  
  def client_array
    @clients = Client.find(:all)
    array = []
    @clients.each do |client|
      array << '"'+client.fullname+'", '
    end
    return "["+array.to_s.chop.chop+"]"
  end
  
  def checklist_status(checklist)
    checklist.complete? ? image_tag('/images/icons/accept.png', :alt => "True") : ""
  end
  
  def fullname_helper(ticket)
    if ticket.client
      return ticket.client.fullname
    else
      return "name not found"
    end
  end
end

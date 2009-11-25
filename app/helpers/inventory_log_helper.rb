module InventoryLogHelper
  def log_item_helper(item)
    user_link = link_to(item.user.name, client_path(item.user.client), :class => 'user')
    item_link = link_to(item.item.name, 'javascript:void(0)', "data-item-id" => item.item.id, :class => 'item')
    destination_link = if item.destination
      if item.destination['type'] == 'ticket'
        !item.destination['id'].blank? ? link_to("Ticket ##{item.destination['id']}", ticket_path(Ticket.find(item.destination['id'])), :class => 'destination') : "Store"
      elsif item.destination['type'] == 'location'
        !item.destination['id'].blank? ? link_to(Location.find(item.destination['id']).name, 'javascript:void(0)', :class => 'destination') : "Store"
      end
    end
    source_link = if item.source
      if item.source['type'] == 'ticket'
        !item.source['id'].blank? ? link_to("Ticket ##{item.source['id']}", ticket_path(Ticket.find(item.source['id'])), :class => 'source') : "Store"
      elsif item.source['type'] == 'location'
        !item.source['id'].blank? ? link_to(Location.find(item.source['id']).name, 'javascript:void(0)', :class => 'source') : "Store"
      end
    end
    string = "#{user_link} <span class='action'>#{item.action.downcase}</span> <span class='quantity'>#{item.quantity}x</span> #{item_link} "
    if item.action == "Added"
      string << "to #{destination_link}"
      if item.device_id
        string << " and <span class='device'>Device #{item.device.service_tag}</span>"
      end
      string << " from #{source_link}"
    elsif item.action == "Moved"
      string << "to #{destination_link}"
    elsif item.action == "Removed"
      string << "from #{source_link}"
      if item.device_id
        string << " and <span class='device'>Device #{item.device.service_tag}</span>"
      end
    end
    string << " at #{item.created_at.strftime('%I:%M%p on %x')}"
  end
end
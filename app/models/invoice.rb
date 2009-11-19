class Invoice
  def self.create_for(ticket)
    begin
      client = Client.find(ticket.client_id)

      # set these variables to be used later
      needs_attention = 0
      drive_time = 0
      line_items = []
      array = TicketEntry.find_all_by_ticket_id(ticket.id) + TicketItem.find_all_by_ticket_id(ticket.id)
      ticket_entries = array.sort_by(&:created_at)
      # iterate thru my ticket entries
      ticket_entries.each do |te|
        if te.class.name == "TicketEntry"
          line_item = {}
          if !te.labor_type.blank?
            if !te.time.blank? || !te.drive_time.blank?
              if te.billable == true
                line_item[:ItemRef] = {:ListID => te.labor_type.qb_id}
              else
                line_item[:ItemRef] = {:ListID => LaborType.warranty.qb_id}
              end
              line_item[:Desc] = te.note+" [#{te.initials}] #{te.created_at.strftime('%m-%d-%y')} Ticket ##{te.ticket.id}"
              line_item[:Quantity] = Invoice.calculate_quantity(te.time, te.labor_type)
              line_items << line_item
            end
          end
          # add 1 to needs_attention if there are any parts on the ticket
          !te.parts.blank? ? needs_attention += 1 : true
          # if there is drive time and its billable, add it to my drive_time var
          if !te.drive_time.blank? && te.billable?
            drive_time += te.drive_time
          end
        else
          # add parts to ticket
          line_item = {}
          line_item[:ItemRef] = {:ListID => te.item.qb_id}
          line_item[:Quantity] = te.quantity
          line_items << line_item
        end
      end
      # add drive time line item
      if drive_time != 0
        line_item = {}
        line_item[:ItemRef] = {:ListID => LaborType.drive_time.qb_id}
        line_item[:Desc] = "Drive time."
        line_item[:Quantity] = Invoice.calculate_quantity(drive_time, LaborType.drive_time)
        line_items << line_item
      end

      # set is to be printed
      needs_attention == 0 ? is_to_be_printed = true : is_to_be_printed = false

      # create the invoice
      invoice = QB::Invoice.new(
                          :CustomerRef => {:ListID => client.qb_id},
                          :TxnDate => Date.today,
                          :InvoiceLine => line_items,
                          :IsToBePrinted => is_to_be_printed,
                          :CustomerMsg => QB::CustomerMsg.first()
                          )
    rescue
      return false
    end
  end
  

  def self.calculate_quantity(time, labor_type)
    if labor_type.service_item_type == "time_based_rate"
      ((time.to_f/labor_type.divisor.to_f)*100).round/100.0
    elsif labor_type.service_item_type == "flat_rate"
      1
    else
      0
    end
  end
end
class Invoice
  def self.create_for(ticket)
    client = Client.find(ticket.client_id)

    # set these variables to be used later
    needs_attention = 0
    drive_time = 0
    
    # iterate thru my ticket entries
    line_items = []

    ticket.ticket_entries.each do |te|
      line_item = {}
      if !te.labor_type.blank?
        if !te.time.blank? || !te.drive_time.blank?
          if te.billable == true
            line_item[:ItemRef] = te.labor_type.qb_lookup.to_ref
          else
            line_item[:ItemRef] = LaborType.warranty.qb_lookup.to_ref
          end
          line_item[:Desc] = te.note+" [#{te.initials}] #{te.created_at.strftime('%m-%d-%y')} Ticket ##{te.ticket.id}"
          line_item[:Quantity] = ((te.time.to_f/te.labor_type.divisor.to_f)*100).round/100.0
          line_items << line_item
        end
      end
      !te.parts.blank? ? needs_attention += 1 : true
      if !te.drive_time.blank? && te.billable?
        drive_time += te.drive_time
      elsif !te.drive_time.blank? && !te.billable?
        line_item[:Quantity] += te.drive_time
      end
    end
    
    # add drive time line item
    if drive_time != 0
      line_item = {}
      line_item[:ItemRef] = LaborType.drive_time.qb_lookup.to_ref
      line_item[:Desc] = "Drive time."
      line_item[:Quantity] = drive_time/LaborType.drive_time.divisor
      line_items << line_item
    end

    # set is to be printed
    needs_attention == 0 ? is_to_be_printed = true : is_to_be_printed = false

    # create the invoice
    invoice = QB::Invoice.new(
                        :CustomerRef => client.qb_lookup.to_ref,
                        :InvoiceLine => line_items,
                        :IsToBePrinted => is_to_be_printed,
                        :CustomerMsg => QB::CustomerMsg.first()
                        )
    # return invoice
  end
end
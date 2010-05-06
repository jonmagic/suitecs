class Invoice
  def self.create_for(ticket, invoice_number=nil)
    # begin
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
              line_item[:Quantity] = Invoice.calculate_quantity(te.time, te.labor_type)
              line_item[:Desc] = te.note+" [#{te.initials}] #{te.created_at.strftime('%m-%d-%y')} Ticket ##{te.ticket.id}"
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
          line_item[:Desc] = "#{te.item.description} [Serial# #{te.serial_number}] (Device: #{te.device.service_tag})"
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
      if invoice_number != nil
        if invoice = QB::Invoice.first(:RefNumber => invoice_number.to_s, :IncludeLineItems => true)
          invoice_mod = invoice.to_element
          # preserve the existing line items
          existing_lines = invoice_mod[:InvoiceLineMod]
          line_mods = []
          existing_lines.each do |line|
            line_mods << QB::InvoiceLineMod.new(:TxnLineID => line[:TxnLineID])
          end
          line_items.each do |line_item|
            new_line_item = QB::InvoiceLineMod.new(:ItemRef => line_item[:ItemRef], :Quantity => line_item[:Quantity], :Desc => line_item[:Desc])
            new_line_item[:TxnLineID] = '-1'
            line_mods << new_line_item
          end
          invoice_mod.delete(:InvoiceLineMod)
          invoice_mod.attributes.concat(line_mods)
          if invoice_mod.valid?
            save_ret = Quickbooks.execute(QB::InvoiceModRq.new(:InvoiceMod => invoice_mod))
            invoice = save_ret[:QBXMLMsgsRs][:InvoiceModRs][0][:InvoiceRet].to_model
          else
            Rails.logger.info "Invoice is not valid for save."
          end
        else
          Rails.logger.info "Failed to find invoice."
        end
      else
        invoice = QB::Invoice.new(
                            :CustomerRef => {:ListID => client.qb_id},
                            :TxnDate => Date.today,
                            :InvoiceLine => line_items,
                            :IsToBePrinted => is_to_be_printed,
                            :CustomerMsg => QB::CustomerMsg.first()
                            )
        if invoice.save
          invoice.instance_variable_set(:@new_record, false)
          return invoice
        else
          Rails.logger.info invoice.save
        end
      end
    # rescue
    #   return false
    # end
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
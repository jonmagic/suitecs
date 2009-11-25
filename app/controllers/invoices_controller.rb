class InvoicesController < ApplicationController
  before_filter :login_required

  def create
    # Lookup my ticket and my client
    ticket = Ticket.find(params[:ticket_id])

    invoice_saved = false
    if !ticket.client.qb_id.blank?
      !params[:invoice_number].blank? ? invoice = Invoice.create_for(ticket, params[:invoice_number]) : invoice = Invoice.create_for(ticket)
      invoice_saved = !invoice.new_record?
    end

    if invoice_saved
      Quickbooks.connection.close
      ticket.invoiced = true
      ticket.save
      invoice[:IsToBePrinted].to_s == "false" ? NotificationMailer.deliver_attention(ticket, invoice) : "No need"
      TicketEntry.create(:entry_type => "Invoice", :note => "Invoice ##{invoice[:RefNumber].to_s}", :billable => false, :private => false, :detail => 1, :ticket => ticket, :creator_id => current_user.id)

      flash[:notice] = "Invoice successfully created."
      redirect_to url_for(ticket)
    else
      Quickbooks.connection.close

      flash[:notice] = "Problem creating the invoice."
      redirect_to url_for(ticket)
    end
  end

end
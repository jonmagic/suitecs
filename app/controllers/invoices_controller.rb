class InvoicesController < ApplicationController
  before_filter :login_required

  def create
    # Lookup my ticket and my client
    ticket = Ticket.find(params[:ticket_id])

    invoice_saved = false
    unless ticket.client.qb_id.blank?
      invoice = params[:invoice_number].blank? ? Invoice.create_for(ticket) : Invoice.create_for(ticket, params[:invoice_number])
      invoice_saved = !invoice.new_record?
    end

    if invoice_saved
      Quickbooks.connection.close
      ticket.invoiced = true
      # ticket.user_id = User.find_by_name("Customer Service").id
      # ticket.active_on = 7.days.from_now.to_date
      # ticket.completed_on = nil
      ticket.save
      invoice[:IsToBePrinted].to_s == "false" ? Navvy::Job.enqueue(NotificationMailer, :deliver_attention, ticket.id, invoice[:RefNumber]) : "No need"
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
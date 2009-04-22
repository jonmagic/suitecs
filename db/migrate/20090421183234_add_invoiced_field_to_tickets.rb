class AddInvoicedFieldToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :invoiced, :boolean
  end

  def self.down
    remove_column :tickets, :invoiced
  end
end

class Client < ActiveRecord::Base
  def self.import_qb(qb_id, name, firstname, lastname, company, note, email_address, phone, fax, alt_phone, bill_address, ship_address)
    unless Client.find_by_qb_id(qb_id)
      if client = Client.create(:name => name, :firstname => firstname, :lastname => lastname, :company => company, :note => note)
        Email.create(:client_id => client.id, :context => 'Primary', :address => email_address) if !email_address.blank?

        Phone.create(:client_id => client.id, :context => 'Primary', :number => phone) if !phone.blank?
        Phone.create(:client_id => client.id, :context => 'Fax', :number => fax) if !fax.blank?
        Phone.create(:client_id => client.id, :context => 'Secondary', :number => phone) if !alt_phone.blank?

        Address.create(:client_id => client.id, :context => 'Billing', :full_address => bill_address) if !bill_address.blank?
        Address.create(:client_id => client.id, :context => 'Shipping', :full_address => bill_address) if !ship_address.blank?
      end
    end
  end

  def self.rescue!(fullname)
    puts "ERRORED on #{fullname.inspect}!"
  end
end

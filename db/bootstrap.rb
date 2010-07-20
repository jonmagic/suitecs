# Setup Users & Their respective clients
cambriatool = Client.create(:name => "Cambria Tool", :company => true)
technician_role = Role.create(:name => 'technician')
[
  {:firstname => "Troy", :lastname => "Balser", :email => "troy@cambriatool.com", :password => "cambria"}
].each do |employee|
  client = Client.create(:firstname => employee[:firstname], :lastname => employee[:lastname], :belongs_to => cambriatool.id)
  user = User.create do |u|
    u.email = employee[:email]
    u.password = u.password_confirmation = employee[:password]
    u.client_id = client.id
  end
  user.register!
  user.activate!
  user.roles << technician_role
  user.update_attributes(:name => client.fullname)
end

require 'fastercsv'

FasterCSV.foreach("#{RAILS_ROOT}/db/CUSTOMER.CSV") do |row|
  if row[1].present?
    billing_street  = row[5].present?  ? row[5]  : ""
    billing_city    = row[7].present?  ? row[7]  : ""
    billing_state   = row[8].present?  ? row[8]  : ""
    billing_zip     = row[9].present?  ? row[9]  : ""
    phone           = row[21].present? ? row[21] : ""
    email           = row[24].present? ? row[24] : ""
    shipping_street = row[13].present? ? row[13] : ""
    shipping_city   = row[15].present? ? row[15] : ""
    shipping_state  = row[16].present? ? row[16] : ""
    shipping_zip    = row[17].present? ? row[17] : ""    
    note            = row[4].present?  ? "Contact Person: #{row[4]}" : ""
    c = Client.create(:name => row[1], :company => true, :note => note)
    if billing_street.present? && billing_city.present? && billing_state.present? && billing_zip.present?
      Address.create(:client => c, :context => "Billing", :thoroughfare => billing_street, :city => billing_city, :state => billing_state, :zip => billing_zip)
    end
    if shipping_street.present? && shipping_city.present? && shipping_state.present? && shipping_zip.present?
      Address.create(:client => c, :context => "Shipping", :thoroughfare => shipping_street, :city => shipping_city, :state => shipping_state, :zip => shipping_zip)
    end
    Phone.create(:client => c, :context => "Work", :number => phone) if phone.present?
    Email.create(:client => c, :context => "Work", :address => email) if email.present?
  end
end

# # Setup some clients
# jon = Client.create(:firstname => "Jonathan", :lastname => "Hoyt", :belongs_to => sabretech.id, :note => "Whatever I want it to be...")
# # Setup some client attributes
# jon_cell = Phone.create(:client => jon, :context => "Cell", :number => "5175551212")

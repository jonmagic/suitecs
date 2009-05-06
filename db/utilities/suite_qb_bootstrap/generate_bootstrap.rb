puts "Job Starting!"
$bootstrap = File.open('import_clients_from_qb.rb', 'w')
$bootstrap << File.read('db/utilities/suite_qb_bootstrap/bootstrap_bootstrap.rb')
$bootstrap << "puts \"Bootstrap Begin!\"\n"

class Addresser
  def self.parse(qb_address_block)
    return '' unless qb_address_block
    hit_numeric = false
    keep_lines = []
    qb_address_block.attributes.each do |line|
      hit_numeric = true if line.to_s =~ /\d/
      keep_lines << line if hit_numeric
    end
    return keep_lines.join(', ')
  end
end

# def self.import_qb(qb_id, name, firstname, lastname, company, note, email_address, phone, fax, alt_phone, bill_address, ship_address)
QB::Customer.each do |customer|
  bill_address_street   = customer[:BillAddress][:Addr2]
  bill_address_city     = customer[:BillAddress][:City]
  bill_address_state    = customer[:BillAddress][:State]
  bill_address_zip      = customer[:BillAddress][:PostalCode]
  ship_address_street   = customer[:ShipAddress][:Addr2]
  ship_address_city     = customer[:ShipAddress][:City]
  ship_address_state    = customer[:ShipAddress][:State]
  ship_address_zip      = customer[:ShipAddress][:PostalCode]
  $bootstrap << "Client.import_qb(#{customer[:ListID].to_s.inspect}, #{customer[:CompanyName].to_s.inspect}, #{customer[:FirstName].to_s.inspect}, #{customer[:LastName].to_s.inspect}, #{!customer[:CompanyName].blank?}, #{customer[:Notes].to_s.inspect}, #{customer[:Email].to_s.inspect}, #{customer[:Phone].to_s.inspect}, #{customer[:Fax].to_s.inspect}, #{customer[:AltPhone].to_s.inspect}, #{bill_address_street.to_s.inspect}, #{bill_address_city.to_s.inspect}, #{bill_address_state.to_s.inspect}, #{bill_address_zip.to_s.inspect}, #{ship_address_street.to_s.inspect}, #{ship_address_city.to_s.inspect}, #{ship_address_state.to_s.inspect}, #{ship_address_zip.to_s.inspect}) rescue Client.rescue!(#{customer[:FullName].to_s.inspect})\n"
end

Quickbooks.connection.close

$bootstrap << "puts \"Bootstrap End!\""
$bootstrap.close
puts "Job Completed!"

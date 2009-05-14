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
  if customer[:BillAddress]
    customer[:BillAddress][:Addr2] != nil ? bill_address_street = customer[:BillAddress][:Addr2] : bill_address_street = ""
    customer[:BillAddress][:City] != nil  ? bill_address_city = customer[:BillAddress][:City] : bill_address_city = ""
    customer[:BillAddress][:State] != nil ? bill_address_state = customer[:BillAddress][:State] : bill_address_state = ""
    customer[:BillAddress][:PostalCode] != nil ? bill_address_zip = customer[:BillAddress][:PostalCode] : bill_address_zip = ""
  end
  
  if customer[:FullName].to_s.inspect.include?(", ") && customer[:CompanyName] == nil
    customer[:FirstName] == nil ? firstname = '"'+customer[:FullName].to_s.inspect.split(", ")[1] : firstname = customer[:FullName].to_s.inspect
    customer[:LastName] == nil  ? lastname = customer[:FullName].to_s.inspect.split(", ")[0]+'"' : firstname = customer[:LastName].to_s.inspect
    company = false
  elsif !customer[:FullName].to_s.inspect.include?(", ") || customer[:LastName] == nil
    customer[:CompanyName] != nil ? name = customer[:CompanyName].to_s.inspect : name = customer[:FullName].to_s.inspect
    company = true
  end
  
  !firstname.blank? ? true : firstname = '""'
  !lastname.blank? ? true : lastname = '""'
  !name.blank? ? true : name = '""'

  $bootstrap << "Client.import_qb(#{customer[:ListID].to_s.inspect}, #{name}, #{firstname}, #{lastname}, #{company}, #{customer[:Notes].to_s.inspect}, #{customer[:Email].to_s.inspect}, #{customer[:Phone].to_s.inspect}, #{customer[:Fax].to_s.inspect}, #{customer[:AltPhone].to_s.inspect}, #{bill_address_street.to_s.inspect}, #{bill_address_city.to_s.inspect}, #{bill_address_state.to_s.inspect}, #{bill_address_zip.to_s.inspect}) rescue Client.rescue!(#{customer[:FullName].to_s.inspect})\n"
end

Quickbooks.connection.close

$bootstrap << "puts \"Bootstrap End!\""
$bootstrap.close
puts "Job Completed!"
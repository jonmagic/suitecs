require 'rubygems'
require 'quickbooks'

puts "Job Starting!"
$bootstrap = File.open('../../../import_clients_from_qb.rb', 'w')
$bootstrap << File.read('db/utilities/suite_qb_bootstrap/bootstrap_bootstrap.rb')
$bootstrap << "puts \"\nBootstrap Begin!\n\""

# uncomment the following line (and comment the one below it) and replace with similar line from config/environments/production.rb to connect to QB on a remote computer
# Quickbooks.use_adapter :https, 'address', 'SuiteCS', 'secret'
Quickbooks.use_adapter :ole, "SuiteCS"

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
  bill_address = Addresser.parse(customer[:BillAddressBlock])
  ship_address = Addresser.parse(customer[:ShipAddressBlock])
  $bootstrap << "Client.import_qb(#{customer[:ListID].to_s.inspect}, #{customer[:CompanyName].to_s.inspect}, #{customer[:FirstName].to_s.inspect}, #{customer[:LastName].to_s.inspect}, #{!customer[:CompanyName].blank?}, #{customer[:Notes].to_s.inspect}, #{customer[:Email].to_s.inspect}, #{customer[:Phone].to_s.inspect}, #{customer[:Fax].to_s.inspect}, #{customer[:AltPhone].to_s.inspect}, #{bill_address.inspect}, #{ship_address.inspect}) rescue Client.rescue!(#{customer[:FullName].to_s.inspect})\n"
end

Quickbooks.connection.close

$bootstrap << "puts \"Bootstrap End!\""
$bootstrap.close
puts "Job Completed!"

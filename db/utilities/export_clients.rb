puts "Job Starting!"
$bootstrap = File.open('clients.sql', 'w')

Client.find(:all).each do |client|
  client.name != nil && client.name != "" ? company_name = "E'"+client.name+"'" : company_name = "NULL"
  client.firstname != nil && client.firstname != "" ? firstname = "E'"+client.firstname+"'" : firstname = "NULL"
  client.lastname != nil && client.lastname != "" ? lastname = "E'"+client.lastname+"'" : lastname = "NULL"
  client.belongs_to != nil && client.belongs_to != "" ? belongs_to = client.belongs_to.to_s : belongs_to = "NULL"
  client.note != nil && client.note != "" ? note = "E'"+client.note.to_s.inspect[1..-2]+"'" : note = "NULL"
  client.mugshot_file_name != nil && client.mugshot_file_name != "" ? mugshot_filename = "'"+client.mugshot_file_name+"'" : mugshot_filename = "NULL"
  client.mugshot_content_type != nil && client.mugshot_content_type != "" ? mugshot_content_type = "'"+client.mugshot_content_type+"'" : mugshot_content_type = "NULL"
  client.mugshot_file_size != nil ? mugshot_file_size = client.mugshot_file_size : mugshot_file_size = "NULL"
  client.qb_id != nil && client.qb_id != "" ? qb_id = "'"+client.qb_id+"'" : qb_id = "NULL"
  client.created_at != nil && client.created_at != "" ? created_at = "'"+client.created_at.to_s+"'" : created_at = "NULL"
  client.updated_at != nil && client.updated_at != "" ? updated_at = "'"+client.updated_at.to_s+"'" : updated_at = "NULL"
  $bootstrap << "INSERT INTO clients VALUES (#{client.id},#{company_name},#{firstname},#{lastname},#{!client.company.blank?},#{belongs_to},#{note},#{mugshot_filename},#{mugshot_content_type},#{mugshot_file_size},#{qb_id},#{created_at},#{updated_at});\n"
end

$bootstrap.close
puts "Job Done!"
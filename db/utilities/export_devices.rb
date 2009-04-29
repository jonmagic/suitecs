puts "Job Starting!"
$bootstrap = File.open('devices.sql', 'w')

Device.find(:all).each do |d|
  d.name != nil && d.name != "" ? name = "'"+d.name+"'" : name = "NULL"
  d.description != nil && d.description != "" ? description = "'"+d.description.to_s.inspect[1..-2]+"'" : description = "NULL"
  d.created_at != nil && d.created_at != "" ? created_at = "'"+d.created_at.to_s+"'" : created_at = "NULL"
  d.updated_at != nil && d.updated_at != "" ? updated_at = "'"+d.updated_at.to_s+"'" : updated_at = "NULL"
  $bootstrap << "INSERT INTO devices VALUES (#{d.id},'#{d.service_tag}',#{name},#{description},#{d.device_type_id},#{d.client_id},#{created_at},#{updated_at});\n"
end

$bootstrap.close
puts "Job Done!"
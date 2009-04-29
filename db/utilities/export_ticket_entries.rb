puts "Job Starting!"
$bootstrap = File.open('ticket_entries.sql', 'w')

TicketEntry.find(:all).each do |te|
  te.entry_type != nil && te.entry_type != "" ? entry_type = "'"+te.entry_type+"'" : entry_type = "NULL"
  te.note != nil && te.note != "" ? note = "'"+te.note.to_s.inspect[1..-2]+"'" : note = "NULL"
  te.time != nil ? time = te.time.to_s : time = "NULL"
  billable = !te.billable.blank?
  prvt = !te.private.blank?
  te.detail != nil ? detail = te.detail.to_s : detail = "NULL"
  te.creator_id != nil ? creator_id = te.creator_id.to_s : creator_id = "NULL"
  te.ticket_id != nil ? ticket_id = te.ticket_id.to_s : ticket_id = "NULL"
  te.created_at != nil && te.created_at != "" ? created_at = "'"+te.created_at.to_s+"'" : created_at = "NULL"
  te.updated_at != nil && te.updated_at != "" ? updated_at = "'"+te.updated_at.to_s+"'" : updated_at = "NULL"
  te.labor_type != nil && te.labor_type != "" ? labor_type = "'"+te.labor_type+"'" : labor_type = "NULL"
  te.parts != nil && te.parts != "" ? parts = "'"+te.parts.to_s.inspect[1..-2]+"'" : parts = "NULL"
  $bootstrap << "INSERT INTO ticket_entries VALUES (#{te.id},#{entry_type},#{note},#{time},#{billable},#{prvt},#{detail},#{creator_id},#{ticket_id},#{created_at},#{updated_at},#{labor_type},#{parts});\n"
end

$bootstrap.close
puts "Job Done!"
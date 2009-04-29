puts "Job Starting!"
$bootstrap = File.open('checklist_items.sql', 'w')

ChecklistItem.find(:all).each do |ci|
  ci.question != nil && ci.question != "" ? question = "'"+ci.question.to_s.inspect[1..-2]+"'" : question = "NULL"
  ci.string != nil && ci.string != "" ? string = "'"+ci.string+"'" : string = "NULL"
  ci.created_at != nil && ci.created_at != "" ? created_at = "'"+ci.created_at.to_s+"'" : created_at = "NULL"
  ci.updated_at != nil && ci.updated_at != "" ? updated_at = "'"+ci.updated_at.to_s+"'" : updated_at = "NULL"
  $bootstrap << "INSERT INTO checklist_items VALUES (#{ci.id},#{ci.checklist_id},#{question},'#{ci.answer_type}',NULL,#{!ci.boolean.blank?},NULL,NULL,NULL,NULL,NULL,#{string},NULL,NULL,#{!ci.completed.blank?},#{created_at},#{updated_at});\n"
end

$bootstrap.close
puts "Job Done!"
class LaborType < ActiveRecord::Base
  has_many :ticket_entries
  
end
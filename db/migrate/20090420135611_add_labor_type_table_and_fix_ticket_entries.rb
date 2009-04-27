class AddLaborTypeTableAndFixTicketEntries < ActiveRecord::Migration
  def self.up
    # we're creating a relationship between ticket entries and labor types, so we'll add the id field first
    add_column :ticket_entries, :labor_type_id, :integer
    
    # now lets create the labor type field
    create_table :labor_types do |t|
      t.string :name
      t.string :qb_id
      t.boolean :visible, :default => true
      t.deletestamps(true)
    end
    
    # now lets create some default labor types
    ["Onsite", "Instore", "Remote", "System Build", "Warranty"].each do |l|
      LaborType.create(:name => l)
    end
    LaborType.create(:name => "Drive Time", :visible => false)
    
    # assign my variables
    onsite = LaborType.find(:first, :conditions => {:name => "Onsite"})
    instore = LaborType.find(:first, :conditions => {:name => "Instore"})
    remote = LaborType.find(:first, :conditions => {:name => "Remote"})
    system_build = LaborType.find(:first, :conditions => {:name => "System Build"})
    warranty = LaborType.find(:first, :conditions => {:name => "Warranty"})
    
    # Now we can fix all the ticket entries
    TicketEntry.find(:all).each do |te|
      if te.labor_type == "Onsite"
        te.labor_type_id = onsite.id
      elsif te.labor_type == "Instore"
        te.labor_type_id = instore.id
      elsif te.labor_type == "Remote"
        te.labor_type_id = remote.id
      elsif te.labor_type == "System Build"
        te.labor_type_id = system_build.id
      elsif te.labor_type == "Warranty"
        te.labor_type_id = warranty.id
      end
      te.save
    end
    # 
    # # And finally remove the labor_type field
    remove_column :ticket_entries, :labor_type
  end

  def self.down
    onsite = LaborType.find(:first, :conditions => {:name => "Onsite"})
    instore = LaborType.find(:first, :conditions => {:name => "Instore"})
    remote = LaborType.find(:first, :conditions => {:name => "Remote"})
    system_build = LaborType.find(:first, :conditions => {:name => "System Build"})
    warranty = LaborType.find(:first, :conditions => {:name => "Warranty"})
    
    add_column :ticket_entries, :labor_type, :string
    
    TicketEntry.find(:all).each do |te|
      if te.labor_type_id == onsite.id
        te.labor_type = "Onsite"
      elsif te.labor_type_id == instore.id
        te.labor_type = "Instore"
      elsif te.labor_type_id == remote.id
        te.labor_type = "Remote"
      elsif te.labor_type_id == system_build.id
        te.labor_type = "System Build"
      elsif te.labor_type_id == warranty.id
        te.labor_type = "Warranty"
      end
      te.save
    end
    
    remove_column :ticket_entries, :labor_type_id
    drop_table :labor_types
  end
end

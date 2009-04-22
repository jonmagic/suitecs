class AddVisibleFieldToLaborTypes < ActiveRecord::Migration
  def self.up
    add_column :labor_types, :visible, :boolean, :default => true
    LaborType.create(:name => "Drive Time", :visible => false)
  end

  def self.down
    remove_column :labor_types, :visible
  end
end

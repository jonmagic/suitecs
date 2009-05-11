class AddServiceItemTypeToLaborTypes < ActiveRecord::Migration
  def self.up
    add_column :labor_types, :service_item_type, :string
  end

  def self.down
    remove_column :labor_types, :service_item_type
  end
end

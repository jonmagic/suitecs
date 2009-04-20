class AddDivisorFieldToLaborTypesTable < ActiveRecord::Migration
  def self.up
    add_column :labor_types, :divisor, :integer
  end

  def self.down
    remove_column :labor_types, :divisor
  end
end

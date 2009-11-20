class InventoryLogController < ApplicationController
  layout 'inventory'
  def index
    @log_items = InventoryLog.all(:order => 'created_at Desc', :limit => 100)
  end
end
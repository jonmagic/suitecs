class InventoryController < ApplicationController
  before_filter :login_required
  
  def index
    if params[:q]
      queries = params[:q].split(' ')
      if queries.length > 1
        items = []
        queries.each do |q|
          Item.all(:_keywords => /#{q}/i, :active => true).each { |i| items << i }
        end
        hash = {}
        items.each do |item|
          if hash[item.id]
            hash[item.id]["count"] += 1
          else  
            hash[item.id] = {}
            hash[item.id]["count"] = 1
            hash[item.id]["object"] = item
          end
        end
        array = []
        hash.each { |k, v| array << v["object"] if v["count"] > 1 }
        @items = []
        array.each.collect do |item|
          count = 0
          queries.each do |q|
            count += 1 if item._keywords.include?(q)
          end
          @items << item if count == queries.length
        end
      else
        @items = Item.all(:_keywords => /#{params[:q]}/i, :active => true)
      end
      Rails.logger.info @items.length
      respond_to do |format|
        format.html { render :partial => 'inventory/items', :layout => false }
        format.json
      end
    end
  end
  
  def show
    @item = Item.find(params[:id])
    render :layout => false
  end
  
  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end
end
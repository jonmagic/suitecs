ActionController::Routing::Routes.draw do |map|

  # Restful Authentication
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.create_password '/create_password/:reset_code', :controller => 'passwords', :action => 'create_password'
  map.resources :users
  map.resources :passwords
  map.resource :session

  # Main Resources
  map.search_clients '/clients/search', :controller => 'clients', :action => 'search'
  map.search_clients_by_phone '/clients/phone_search', :controller => 'clients', :action => 'search'
  map.all_clients '/clients/all', :controller => 'clients', :action => 'all'
  map.stats '/clients/stats', :controller => 'clients', :action => 'stats'
  map.resources :clients do |client|
    client.resources :tickets
    client.resources :devices
    client.resources :users
  end
  map.search_tickets '/tickets/search', :controller => 'tickets', :action => 'search'
  map.calendar_tickets '/tickets/calendar.json', :controller => 'tickets', :action => 'calendar'
  map.resources :tickets do |ticket|
    ticket.resources :ticket_entries
    ticket.resources :ticket_items
    ticket.resources :devices
    ticket.resources :checklists
  end
  map.download_sma '/devices/:device_id/download_sma', :controller => 'devices', :action => 'download_sma'
  map.resources :devices do |device|
    device.resources :checklists
    device.resources :tickets
    device.resources :sentries
  end

  # Secondary Resources
  map.resources :ticket_entries
  map.resources :device_types
  map.resources :sentries do |sentry|
    sentry.resources :events
  end
  map.resources :settings
  map.resources :reports
  map.resources :things
  map.resources :checklists
  map.resources :checklist_templates
  map.resources :goggles
  map.resources :schedules
  map.resources :radchecks
  map.resources :sentries
  map.resources :labor_types
  map.resources :qb_client_connector
  map.resources :invoices
  map.inventory_activity '/inventory/activity', :controller => 'inventory_log', :action => 'index'
  map.inventory_activity_search '/inventory/activity/search', :controller => 'inventory_log', :action => 'search'
  map.resources :inventory
  map.resources :locations
  map.resources :ticket_items
  map.ticket_item_by_barcode '/tickets/:ticket_id/ticket_items/barcode/:id', :controller => 'ticket_items', :action => 'barcode'
  map.ticket_item_by_item_id '/tickets/:ticket_id/ticket_items/item_id/:id', :controller => 'ticket_items', :action => 'item_id'
  map.resources :calendar
  
  # Custom Routes
  map.device_details '/tickets/:ticket_id/devices/:id/details', :controller => 'devices', :action => 'details'
  map.add_to_ticket '/tickets/:ticket_id/devices/:id/add_to_ticket', :controller => 'devices', :action => 'add_to_ticket'
  map.remove_device_from_ticket '/tickets/:ticket_id/devices/:id/remove_from_ticket', :controller => 'devices', :action => 'remove_from_ticket'
  map.add_association '/checklist_templates/:checklist_template_id/device_types/:id/add_association', :controller => 'checklist_templates', :action => "add_assocation"
  map.remove_association '/checklist_templates/:checklist_template_id/device_types/:id/remove_association', :controller => 'checklist_templates', :action => "remove_assocation"
  map.remove_checklist_from_ticket '/tickets/:ticket_id/checklists/:id/remove_from_ticket', :controller => 'checklists', :action => 'remove_from_ticket'

  # iPhone routes
  map.namespace :iphone do |iphone|
    iphone.resources :clients do |client|
      client.resources :tickets
      client.resources :devices
    end
    iphone.resources :tickets do |ticket|
      ticket.resources :devices
      ticket.resources :ticket_entries
    end
    iphone.resources :devices do |device|
      device.resources :tickets
    end
    iphone.root :controller => 'clients', :action => 'home'
  end
  
  # report routes
  map.namespace :report do |report|
    report.resources :time_sheet
    report.resources :average_hours_comparison
    report.resources :time_per_client
    report.resources :ticket_detail
  end
  
  # Home Page
  map.root :controller => 'tickets', :action => 'index'
  
  # Last but not least
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end

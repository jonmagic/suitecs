class AddDefaultAdminUser < ActiveRecord::Migration
  def self.up
    # create default client
    client = Client.create(:name => APP_CONFIG[:name], :company => true)
    
    # Create admin role
    admin_role = Role.create(:name => 'admin')
    technician_role = Role.create(:name => 'technician')
    
    # Create default admin user
    user = User.create do |u|
      u.password = u.password_confirmation = 'password'
      u.email = APP_CONFIG[:admin_email]
      u.client_id = client.id
    end
    
    # Activate user
    user.register!
    user.activate!
    
    # Add admin role to admin user
    user.roles << admin_role
    user.roles << technician_role
  end

  def self.down
    Role.delete_all
    User.delete_all
  end
end

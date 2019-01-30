class AddAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :acceso_caja, :boolean, default: true
    add_column :users, :acceso_productos, :boolean, default: true
    add_column :users, :acceso_tesoreria, :boolean, default: false 
    add_column :users, :acceso_distribuidora, :boolean, default: false
    add_column :users, :acceso_admin, :boolean, default: false    
  end
end

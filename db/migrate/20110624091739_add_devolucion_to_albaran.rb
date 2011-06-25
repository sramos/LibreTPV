class AddDevolucionToAlbaran < ActiveRecord::Migration
  def self.up
    add_column :albarans, :deposito, :boolean, :default => false
    add_column :albarans, :fecha_devolucion, :date
  end

  def self.down
    remove_column :albarans, :deposito
    remove_column :albarans, :fecha_devolucion
  end
end

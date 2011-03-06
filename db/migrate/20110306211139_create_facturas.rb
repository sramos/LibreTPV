class CreateFacturas < ActiveRecord::Migration
  def self.up
    create_table :facturas do |t|
      t.date :fecha, :null => false, :default => Time.now
      t.integer :albaran_id, :null => false
      t.boolean :metalico, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :facturas
  end
end

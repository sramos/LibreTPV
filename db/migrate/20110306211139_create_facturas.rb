class CreateFacturas < ActiveRecord::Migration
  def self.up
    create_table :facturas do |t|
      t.date :fecha, :null => false
      t.string :codigo, :null => false
      t.decimal :importe, :precision => 8, :scale => 2, :null => false
      t.integer :albaran_id, :null => false
      t.boolean :pagado, :default => false
      t.boolean :metalico, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :facturas
  end
end

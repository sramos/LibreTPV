class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :avisos do |t|
      t.string :mensaje, :null => false
      t.integer :criticidad, :default => 1
      t.boolean :visible, :default => true
      t.string :url
      t.string :objeto, :null => false
      t.integer :objeto_id

      t.timestamps
    end
  end

  def self.down
    drop_table :avisos
  end
end

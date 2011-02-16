class CreateAlbarans < ActiveRecord::Migration
  def self.up
    create_table :albarans do |t|
      t.string :codigo
      t.date :fecha

      t.timestamps
    end
  end

  def self.down
    drop_table :albarans
  end
end

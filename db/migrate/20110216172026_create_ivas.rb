class CreateIvas < ActiveRecord::Migration
  def self.up
    create_table :ivas do |t|
      t.string :nombre
      t.integer :valor

      t.timestamps
    end
  end

  def self.down
    drop_table :ivas
  end
end

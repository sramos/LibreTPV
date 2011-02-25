class CreateCampos < ActiveRecord::Migration
  def self.up
    create_table :campos do |t|
      t.string :nombre
      t.string :tipo

      t.timestamps
    end
  end

  def self.down
    drop_table :campos
  end
end

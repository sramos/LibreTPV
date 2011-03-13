class CreatePagos < ActiveRecord::Migration
  def self.up
    create_table :pagos do |t|
      t.decimal :importe, :precision => 8, :scale => 2, :null => false
      t.date :fecha, :null => false
      t.integer :factura_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pagos
  end
end

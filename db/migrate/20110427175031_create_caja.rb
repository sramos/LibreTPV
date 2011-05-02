class CreateCaja < ActiveRecord::Migration
  def self.up
    create_table :caja do |t|
      t.datetime :fecha_hora, :null => false
      t.decimal :importe, :precision => 8, :scale => 2, :null => false
      t.string :comentarios
      t.boolean :cierre_caja
      t.timestamps
    end
    change_column('pagos', :fecha, :datetime)
  end

  def self.down
    drop_table :caja
  end
end

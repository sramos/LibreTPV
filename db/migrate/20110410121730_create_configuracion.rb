class CreateConfiguracion < ActiveRecord::Migration
  def self.up
    create_table :configuracion do |t|
      t.string :nombre_param
      t.string :valor_param
      t.timestamps
    end
  end

  def self.down
    drop_table :configuracion
  end
end

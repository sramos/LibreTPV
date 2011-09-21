class AddRelacionesEntreLineas < ActiveRecord::Migration
  def self.up
    add_column :albaran_lineas, :linea_descuento_id, :integer
  end

  def self.down
    remove_column :albaran_lineas, :linea_descuento_id
  end
end

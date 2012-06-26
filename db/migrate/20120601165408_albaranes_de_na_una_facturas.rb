class AlbaranesDeNaUnaFacturas < ActiveRecord::Migration
  def self.up
    add_column :albarans, :factura_id, :integer
    Factura.all(:conditions => ["albaran_id IS NOT NULL"]).each do |factura|
      albaran = Albaran.find_by_id factura.albaran_id
      if albaran
        albaran.factura_id = factura.id
        albaran.save
        puts "------------> ERROR: Problemas al guardar albaran " + albaran.id.to_s + ": " + albaran.errors.full_messages.to_s unless albaran.errors.empty?
      else
        puts "------------> ERROR: La factura " + factura.id.to_s + " esta vinculada a un albaran que no existe."
      end
    end
    remove_column :facturas, :albaran_id
  end

  def self.down
    add_column :facturas, :albaran_id, :integer
    Albaran.all(:conditions => ["factura_id IS NOT NULL"]).each do |albaran|
      factura = Factura.find_by_id albaran.factura_id
      if factura
        factura.albaran_id = albaran.id
        factura.save
        puts "------------> ERROR: Problemas al guardar la factura " + factura.id.to_s + ": " + factura.errors.full_messages.to_s unless factura.errors.empty?
      else
        puts "------------> ERROR: El albaran " + albaran.id.to_s + " esta vinculado a una factura que no existe."
      end
    end
    remove_column :albarans, :factura_id
  end
end

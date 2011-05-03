class ModificaFamilia < ActiveRecord::Migration
  def self.up
    add_column :familias, :acumulable, :integer, :default => 0
  end

  def self.down
    remove_column :familias, :acumulable
  end
end

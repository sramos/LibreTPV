class ChangeDescriptionField < ActiveRecord::Migration
  def self.up
    change_column :productos, :descripcion, :text
  end

  def self.down
    change_column :productos, :descripcion, :string
  end
end

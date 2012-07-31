class CreateMateria < ActiveRecord::Migration
  def self.up
    create_table :materia do |t|
      t.string :nombre
      t.timestamps
    end
    add_column :productos, :materia_id, :integer
  end

  def self.down
    remove_column :productos, :materia_id
    drop_table :materia
  end
end

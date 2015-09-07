class AddActualizaWebToFamilia < ActiveRecord::Migration
  def up 
    # Genera los nuevos campos para las materias
    add_column :familias, :sincroniza_web, :boolean, null: false, default: false
  end
  def down
    remove_column :familias, :sincroniza_web
  end
end

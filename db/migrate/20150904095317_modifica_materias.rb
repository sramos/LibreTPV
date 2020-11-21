class ModificaMaterias < ActiveRecord::Migration
  def up
    # Genera los nuevos campos para las materias
    add_column :materia, :valor_defecto, :boolean, null: false, default: false
    add_column :materia, :familia_id, :integer, null: false
    Materia.reset_column_information
    # Crea las materias por defecto
    Familia.all.each do |familia|
      Materia.create(nombre: "General " + familia.nombre, valor_defecto: true, familia_id: familia.id)
    end
    # Recorre todos los libros para ajustar las materias
    puts "------> Revisando relaciones de materias."
    puts "        Puede tardar un rato..."
    Producto.all.each do |producto|
      # Si no tiene materia se la asigna
      if producto.materia_id.nil?
        producto.update_column(:materia_id, Materia.find_by_familia_id_and_valor_defecto(producto.familia_id, true))
      # Si la materia no es de la misma familia...
      elsif producto.materia.familia_id != producto.familia_id
        # Si la materia no tiene aun familia, se le asigna
        if producto.materia.familia_id.nil? || producto.materia.familia_id == 0
          producto.materia.update_column(:familia_id, producto.familia_id)
        # Si si tiene ya asignada una familia, crea una materia nueva para asignarla al producto
        else
          nueva_materia = Materia.find_or_create_by (nombre: producto.materia.nombre, familia_id: producto.familia_id)
          logger.info "---------> ERROR: No se ha podido crear la materia " + producto.materia.nombre + ": " + nueva_materia.errors.inspect unless nueva_materia.errors.empty?
          producto.update_column(:materia_id, nueva_materia) if nueva_materia.errors.empty? 
        end
      end
    end
  end

  def down
    remove_column :materia, :valor_defecto
    remove_column :materia, :familia_id
  end
end

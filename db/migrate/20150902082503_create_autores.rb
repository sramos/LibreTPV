class CreateAutores < ActiveRecord::Migration
  def up
    # Crea la tabla de autores 
    create_table :autor, force: true do |t|
      t.string  :nombre, null: false
      t.timestamps
    end
    # Crea la tabla de relaciones autor <-> producto (N a N)
    create_table :autor_x_producto, force: true do |t|
      t.integer  :autor_id, null: false
      t.integer  :producto_id, null: false
      t.string   :rol
      t.timestamps
    end
    # Mueve los autores a la nueva tabla y establece sus relaciones con cada producto
    puts "------> Generando relaciones con autores."
    puts "        Puede tardar un rato..."
    Producto.where("autor IS NOT NULL AND autor != ''").each do |producto|
      # Obtiene el valor actual del campo "autor", lo convierte a mayusculas y lo divide usando como separador el caracter /
      producto.read_attribute(:autor).strip.mb_chars.upcase.split(%r{\s*/\s*}).each do |str_autor|
        # Genera el autor corrigiendo previamente el nombre:
        #  * Varios espacios se convierten en uno solo
        #  * Se eliminan espacios antes de la coma (separacion de apellido del nombre) 
        nom = str_autor.gsub(/\s+,\s./, ', ').gsub(/\s+/, ' ')
        autor = Autor.find_or_create_by_nombre nom
        puts "        ERROR: Hubo un problema creando el autor: " + nom unless autor.errors.empty?
        axp = AutorXProducto.create(autor_id: autor.id, producto_id: producto.id) if autor.errors.empty?
      end
    end
    # Elimina el campo de texto de autores
    remove_column :productos, :autor
  end

  def down
    # Crea el campo de texto de autores
    add_column :productos, :autor, :string
    # Recarga y sincroniza la referencia
    Producto.reset_column_information
    # Recorre productos e incluye el campo de texto autor
    Producto.all.each do |producto|
      nombres = producto.autor.nil? ? nil : producto.autor.collect{|a| a.nombre}.join(" / ")
      producto.update_column(:autor, nombres)
    end 
    # Elimina las tablas de relacion
    drop_table :autor_x_producto
    drop_table :autor
  end
end

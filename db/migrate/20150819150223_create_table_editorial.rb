class CreateTableEditorial < ActiveRecord::Migration
  def up
    # Crea la tabla de editoriales
    create_table :editorial, force: true do |t|
      t.string  :nombre, null: false

      t.timestamps
    end
    # Genera el campo de relacion en el modelo de productos
    add_column :productos, :editorial_id, :integer
    Producto.reset_column_information
    # Va generando todas las editoriales y vinculándolas a los productos
    puts "------> Generando relaciones con editoriales."
    puts "        Puede tardar un rato..."
    Producto.where("editor != ''").each do |producto|
      editor = Editorial.find_or_create_by_nombre(producto.editor)
      producto.update_attribute(:editorial_id, editor.id) if editor
    end 
    # Eliminamos el campo antiguo de editor
    remove_column :productos, :editor
  end

  def down
    # Genera el campo de texto del editor
    add_column :productos, :editor, :string
    Producto.reset_column_information
    # Actualizamos de nuevo la informacion con las editoriales
    puts "------> Generando relaciones con editoriales."
    puts "        Puede tardar un rato..."
    Producto.where("editorial_id is not null").each do |producto|
      producto.update_attribute(:editor, producto.editorial.nombre) if producto.editorial
    end
    # Eliminamos las tablas duplicadas
    remove_column :productos, :editorial_id
    drop_table :editorial
  end
end

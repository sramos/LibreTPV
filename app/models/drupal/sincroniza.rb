#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2015 Santiago Ramos <sramos@sitiodistinto.net> 
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo 
#    bajo los términos de la Licencia Pública General GNU publicada 
#    por la Fundación para el Software Libre, ya sea la versión 3 
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero 
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita 
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. 
#    Consulte los detalles de la Licencia Pública General GNU para obtener 
#    una información más detallada. 
#
#    Debería haber recibido una copia de la Licencia Pública General GNU 
#    junto a este programa. 
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++


class Drupal::Sincroniza < ActiveRecord::Base
  # Para que no nos exija que exista una tabla en BBDD para esta clase
  self.abstract_class = true

  # Sincroniza todos los autores existentes
  def self.autores
    errores = [] 
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      elemento_type = "Autor"
      # Primero evalua los objetos a borrar
      eliminar = RelacionWeb.where(eliminar: true, elemento_type: elemento_type)
      eliminar.each do |elemento|
        nodo = Drupal::Node.autor.find_by_nid(elemento.nid)
        nodo.destroy if nodo
        errores.push = nodo.errors.full_messages.join(" ") unless nodo.nil? || nodo.errors.empty?
      end
      # Y luego todos los elementos modificados despues de la ultima sincronizacion
      ultima = LogSincronizacionWeb.where(elemento_type: elemento_type, status_ok: true).last
      condicion = ultima ? ["updated_at > ?", ultima.updated_at] : nil
      elementos = Autor.where(condicion)
      logger.info "----> Actualizando " + elementos.count.to_s + " " + elemento_type.pluralize + "..."
      elementos.each do |elemento|
        rw = RelacionWeb.where(elemento_type: elemento_type, elemento_id: elemento.id).first || RelacionWeb.new(elemento_type: elemento_type, elemento_id: elemento.id)
        resultado = Drupal::Sincroniza.autor(rw)
        # Anota si se ha podido actualizar
        if resultado && resultado.nid && resultado.errors.empty?
          # Crea o actualiza la relacion web
          rw.update_attribute(:nid, resultado.nid)
        # O se ha producido un error
        else
          puts "------> ERROR!!!: " + resultado.errors.inspect
          errores.push resultado.errors.full_messages.join(" ") 
        end
      end
      LogSincronizacionWeb.create(elemento_type: elemento_type, status_ok: errores.empty?, eliminados: eliminar.count, actualizados: elementos.count)
    end
  end

  # Sincroniza todas las editoriales
  def self.editoriales
    errores = [] 
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      elemento_type = "Editorial"
      # Primero evalua los objetos a borrar
      eliminar = RelacionWeb.where(eliminar: true, elemento_type: elemento_type)
      eliminar.each do |elemento|
        nodo = Drupal::Node.editorial.find_by_nid(elemento.nid)
        nodo.destroy if nodo
        errores.push = nodo.errors.full_messages.join(" ") unless nodo.errors.empty?
      end
      # Y luego todos los elementos modificados despues de la ultima sincronizacion
      ultima = LogSincronizacionWeb.where(elemento_type: elemento_type, status_ok: true).last
      condicion = ultima ? ["updated_at > ?", ultima.updated_at] : nil
      elementos = Editorial.where(condicion)
      logger.info "----> Actualizando " + elementos.count.to_s + " " + elemento_type.pluralize + "..."
      elementos.each do |elemento|
        rw = RelacionWeb.where(elemento_type: elemento_type, elemento_id: elemento.id).first || RelacionWeb.new(elemento_type: elemento_type, elemento_id: elemento.id)
        resultado = Drupal::Sincroniza.editorial(rw)
        # Anota si se ha podido actualizar
        if resultado && resultado.nid && resultado.errors.empty?
          # Crea o actualiza la relacion web
          rw.update_attribute(:nid, resultado.nid)
        # O se ha producido un error
        else
          puts "------> ERROR!!!: " + resultado.errors.inspect
          errores.push resultado.errors.full_messages.join(" ")
        end
      end
      LogSincronizacionWeb.create(elemento_type: elemento_type, status_ok: errores.empty?, eliminados: eliminar.count, actualizados: elementos.count)
    end
  end
  
  # Sincroniza todas las materias (y familias)
  def self.materias
    errores = [] 
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      elemento_type = "Materia"
      # Primero evalua los objetos a borrar
      eliminar = RelacionWeb.where(eliminar: true, elemento_type: elemento_type)
      logger.info  "----> Eliminando " + eliminar.count.to_s + " " + elemento_type.pluralize + "..."
      eliminar.each do |elemento|
        nodo = Drupal::TaxonomyTermData.materia.find_by_tid(elemento.nid)
        nodo.destroy if nodo
        errores.push = nodo.errors.full_messages.join(" ") unless nodo.nil? || nodo.errors.empty?
        elemento.destroy if nodo.nil? || nodo.errors.empty?
      end
      # Y luego todos los elementos modificados despues de la ultima sincronizacion
      ultima = LogSincronizacionWeb.where(elemento_type: elemento_type, status_ok: true).last
      condicion = ultima ? ["materia.updated_at > ?", ultima.updated_at] : nil
      elementos = Materia.joins(:familia).where("familias.sincroniza_web" => true).where(condicion)
      logger.info "----> Actualizando " + elementos.count.to_s + " " + elemento_type.pluralize + "..."
      elementos.each do |elemento|
        rw = RelacionWeb.where(elemento_type: elemento_type, elemento_id: elemento.id).first || RelacionWeb.new(elemento_type: elemento_type, elemento_id: elemento.id)
        resultado = Drupal::Sincroniza.materia(rw)
        # Anota si se ha podido actualizar
        if resultado && resultado.tid && resultado.errors.empty?
          # Crea o actualiza la relacion web
          rw.update_attribute(:nid, resultado.tid)
        # O se ha producido un error
        else
          puts "------> ERROR!!!: " + resultado.errors.inspect
          errores.push resultado.errors.full_messages.join(" ") 
        end
      end
      LogSincronizacionWeb.create(elemento_type: elemento_type, status_ok: errores.empty?, eliminados: eliminar.count, actualizados: elementos.count)
    end
  end

  # Sincroniza todos los productos
  def self.productos
    errores = false
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      elemento_type = "Producto"
      # Primero evalua los objetos a borrar
      eliminar = RelacionWeb.where(eliminar: true, elemento_type: elemento_type)
      eliminar.each do |elemento|
      end
      # Y luego todos los elementos modificados despues de la ultima sincronizacion
      ultima = LogSincronizacionWeb.where(elemento_type: "producto", status_ok: true).last
      condicion = ultima ? ["producto.updated_at > ?", ultima.updated_at] : nil
      elementos = Producto.joins(:familia).where("familias.sincroniza_web" => true).where(condicion)
      logger.info "----> Actualizando " + elementos.count.to_s + " productos..."
      elementos.each do |elemento|
      end
    end
  end

#private
  # Sincroniza la info de un autor
  def self.autor objeto
    # Si no disponemos aun de nid, buscamos si existiera algun elemento con el mismo nombre
    nodo = Drupal::Node.autor.find_by_nid(objeto.nid) if objeto.nid
    nodo = Drupal::Node.autor.find_by_title(objeto.elemento.nombre) unless objeto.nid
    nodo ||= Drupal::Node.autor.new
    nodo.update_attributes(title: objeto.elemento.nombre)
    return nodo
  end

  # Sincroniza la info de una editorial
  def self.editorial objeto
    # Si no disponemoa aun de nid, buscamos si existiera algun elemento con el mismo nombre
    nodo = Drupal::Node.editorial.find_by_nid(objeto.nid) if objeto.nid
    nodo = Drupal::Node.editorial.find_by_title(objeto.elemento.nombre) unless objeto.nid
    nodo ||= Drupal::Node.editorial.new
    nodo.update_attributes(title: objeto.elemento.nombre)
    return nodo 
  end

  # Sincroniza la info de una materia
  def self.materia objeto
    # Si no disponemos aun de nid, buscamos si existiera algun elemento con el mismo nombre
    nodo = Drupal::TaxonomyTermData.materia.find_by_tid(objeto.nid) if objeto.nid
    nodo = Drupal::TaxonomyTermData.materia.find_by_name(objeto.elemento.nombre) unless objeto.nid
    nodo ||= Drupal::TaxonomyTermData.materia.new
    nodo.update_attributes(name: objeto.elemento.nombre, weight: (objeto.elemento.valor_defecto ? 0 : 1) )
    return nodo
  end

  # Sincroniza la info de una familia
  def self.familia objeto
    if objeto && objeto.class.name == "RelacionWeb"
    end
  end

  # Sincroniza la infor de un producto
  def self.producto objeto
    if objeto && objeto.class.name == "RelacionWeb"
    end
  end

end

# Be sure to restart your server when you modify this file.

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'RESTful'
# end

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
  inflect.irregular 'configuracion', 'configuracion'
  inflect.irregular 'caja', 'caja'
  inflect.irregular 'materia', 'materia'
  inflect.irregular 'familia', 'familias'
  inflect.irregular 'editorial', 'editorial'
  inflect.irregular 'aut or', 'autor'
  inflect.irregular 'autor_x_producto', 'autor_x_producto'
  inflect.irregular 'relacion_web', 'relacion_web'
  inflect.irregular 'log_sincronizacion_web', 'log_sincronizacion_web'
  inflect.irregular 'almacen', 'almacenes'
  inflect.irregular 'producto_editorial', 'productos_editorial'
  inflect.irregular 'producto_editorial_x_almacen', 'producto_editorial_x_almacenes'
end

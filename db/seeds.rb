# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

if User.count == 0
  User.create email: "admin@sitiodistinto.net", password: "Passw0rd", password_confirmation: "Passw0rd",
              name: "Default Admin User",
	      acceso_caja: true, acceso_productos: true,
	      acceso_distribuidora: true, acceso_tesoreria: true,
	      acceso_admin: true
end

Iva.create([		{ :nombre => 'Superreducido', :valor => 4},
			{ :nombre => 'Reducido', :valor => 10},
			{ :nombre => 'General', :valor => 21} ])				if Iva.count == 0

Familia.create([	{ :nombre => 'Libros', :iva => Iva.find_by_nombre('Superreducido') },
			{ :nombre => 'Entradas', :iva => Iva.find_by_nombre('General') },
			{ :nombre => 'Revistas/Periódicos', :iva => Iva.find_by_nombre('Superreducido') },
			{ :nombre => 'Material Escolar', :iva => Iva.find_by_nombre('Superreducido')},
			{ :nombre => 'Papelería', :iva => Iva.find_by_nombre('General') }  ])	if Familia.count == 0

FormaPago.create([	{ :nombre => 'Efectivo', :caja => true}, { :nombre => 'Tarjeta' },
			{ :nombre => 'Transferencia' }, { :nombre => 'Domiciliacion' } ])	if FormaPago.count == 0

Campo.create([		{ :nombre => 'Autor'}, { :nombre => 'Año'}, { :nombre => 'Editor'},
			{ :nombre => 'Coleccion'}, { :nombre => 'Descripcion'}  ])		if Campo.count == 0

Proveedor.create([	{ :nombre => 'Timadores Sin Fronteras',
			:cif => 'A-88554345-J', :descuento => '30' } ] )			if Proveedor.count == 0

Cliente.create([	{ :nombre => 'Caja', :cif => 'N/A' } ] )				if Cliente.count == 0

Configuracion.create([	{ :nombre_param => 'PAGINADO', :valor_param => '25'},
			{ :nombre_param => 'NOMBRE CORTO EMPRESA', :valor_param => 'Librería Ejemplo'},
                        { :nombre_param => 'NOMBRE LARGO EMPRESA', :valor_param => 'Librería Asociativa Ejemplo'},
			{ :nombre_param => 'CIF', :valor_param => 'A-12345678-B'},
			{ :nombre_param => 'DIRECCION', :valor_param => 'c/ Sin Nombre, nº1'},
			{ :nombre_param => 'CODIGO POSTAL', :valor_param => '28053 MADRID' },
			{ :nombre_param => 'TELEFONO', :valor_param => '911760555' },
			{ :nombre_param => 'PREFIJO FACTURA VENTA', :valor_param => 'LIB/2013-'},
			{ :nombre_param => 'FACTURAS VENTA', :valor_param => '0'},
			{ :nombre_param => 'COMANDO IMPRESION', :valor_param => 'lpr -P TM-T70 -o cpi=20', :editable => false} ]) if Configuracion.count == 0

familia_id = Familia.first.id
Materia.create([	{ :nombre => 'Cómic', :familia_id => familia_id }, { :nombre =>'Cuentos', :familia_id => familia_id }, { :nombre => 'Formación/Materias', :familia_id => familia_id },
			{ :nombre => 'Libros para colorear', :familia_id => familia_id  }, {:nombre => 'Literatura clásica', :familia_id => familia_id }, { :nombre => 'Narrativa', :familia_id => familia_id },
			{ :nombre => 'Narrativa breve', :familia_id => familia_id }, { :nombre => 'Narrativa de humor', :familia_id => familia_id }, { :nombre => 'Narrativa erótica', :familia_id => familia_id },
			{ :nombre => 'Narrativa fantástica', :familia_id => familia_id }, { :nombre => 'Narrativa histórica', :familia_id => familia_id }, { :nombre => 'Narrativa idiomas', :familia_id => familia_id },
			{ :nombre => 'Narrativa infantil', :familia_id => familia_id }, { :nombre => 'Narrativa juvenil', :familia_id => familia_id }, { :nombre => 'Narrativa romántica', :familia_id => familia_id },
			{ :nombre => 'Narrativa terror', :familia_id => familia_id }, { :nombre => 'Narrativa viajes', :familia_id => familia_id }, { :nombre => 'Novela gráfica', :familia_id => familia_id },
			{ :nombre => 'Novela negra', :familia_id => familia_id }, { :nombre => 'Poesía', :familia_id => familia_id }, { :nombre => 'Segunda mano', :familia_id => familia_id }, { :nombre => 'Teatro', :familia_id => familia_id },
			{ :nombre => 'Viajes', :familia_id => familia_id }, { :nombre => 'Ensayo', :familia_id => familia_id } ])			if Materia.count == 0

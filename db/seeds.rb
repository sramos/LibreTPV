# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

#Iva.create([		{ :nombre => 'Superreducido', :valor => 4},
#			{ :nombre => 'Reducido', :valor => 8},
#			{ :nombre => 'General', :valor => 18} ])
#
#Familia.create([	{ :nombre => 'Libros', :iva => Iva.find_by_nombre('Superreducido') },
#			{ :nombre => 'Entradas', :iva => Iva.find_by_nombre('Reducido') } ])	
#
#FormaPago.create([	{ :nombre => 'Efectivo', :caja => true}, { :nombre => 'Tarjeta' }, { :nombre => 'Transferencia' }, { :nombre => 'Domiciliacion' } ])
#
#Campo.create([		{ :nombre => 'Autor'}, { :nombre => 'Año'}, { :nombre => 'Editor'}, { :nombre => 'Coleccion'},
#			{ :nombre => 'Descripcion'}  ])
#
#Proveedor.create([	{ :nombre => 'Timadores Sin Fronteras', :cif => 'A-88554345-J', :descuento => '30' } ] )
#
#Cliente.create([	{ :nombre => 'Caja', :cif => 'N/A' } ] )

Configuracion.create([	{ :nombre_param => 'PAGINADO', :valor_param => '25'},
			{ :nombre_param => 'NOMBRE CORTO EMPRESA', :valor_param => 'Librería Ejemplo'},
                        { :nombre_param => 'NOMBRE LARGO EMPRESA', :valor_param => 'Librería Asociativa Ejemplo'},
			{ :nombre_param => 'CIF', :valor_param => 'A-12345678-B'},
			{ :nombre_param => 'DIRECCION', :valor_param => 'c/ Sin Nombre, nº1'},
			{ :nombre_param => 'PREFIJO FACTURA VENTA', :valor_param => 'LIB-'},
			{ :nombre_param => 'COMANDO IMPRESION', :valor_param => 'lpr -P TM-T70 -o cpi=20'} ])


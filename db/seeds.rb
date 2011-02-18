# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Iva.create([		{ :nombre => 'Superreducido', :valor => 4},
			{ :nombre => 'Reducido', :valor => 8},
			{ :nombre => 'General', :valor => 18} ])

Familia.create([	{ :nombre => 'Libros', :iva => Iva.find_by_nombre('Superreducido') },
			{ :nombre => 'Entradas', :iva => Iva.find_by_nombre('Reducido') } ])	

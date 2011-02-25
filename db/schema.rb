# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110220192155) do

  create_table "albaran_lineas", :force => true do |t|
    t.integer  "cantidad"
    t.integer  "descuento"
    t.integer  "producto_id"
    t.integer  "albaran_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albarans", :force => true do |t|
    t.string   "codigo"
    t.date     "fecha"
    t.integer  "proveedor_id"
    t.integer  "cliente_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campos", :force => true do |t|
    t.string   "nombre"
    t.string   "tipo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clientes", :force => true do |t|
    t.string   "nombre"
    t.string   "cif"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "familias", :force => true do |t|
    t.string   "nombre"
    t.integer  "iva_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ivas", :force => true do |t|
    t.string   "nombre"
    t.integer  "valor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productos", :force => true do |t|
    t.integer  "codigo"
    t.string   "nombre"
    t.string   "autor"
    t.string   "editor"
    t.string   "anno"
    t.string   "descripcion"
    t.string   "url_imagen"
    t.integer  "cantidad"
    t.integer  "familia_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "precio",      :precision => 8, :scale => 2, :default => 0.0
  end

  create_table "proveedors", :force => true do |t|
    t.string   "nombre"
    t.string   "cif"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

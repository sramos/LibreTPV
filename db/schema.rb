# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190217103006) do

  create_table "albaran_lineas", force: :cascade do |t|
    t.integer  "cantidad",           limit: 4,                           default: 1
    t.integer  "descuento",          limit: 4,                           default: 0
    t.decimal  "precio_compra",                  precision: 8, scale: 2
    t.decimal  "precio_venta",                   precision: 8, scale: 2
    t.integer  "producto_id",        limit: 4
    t.integer  "albaran_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nombre_producto",    limit: 255
    t.integer  "iva",                limit: 4
    t.integer  "linea_descuento_id", limit: 4
  end

  add_index "albaran_lineas", ["albaran_id"], name: "albaran_lineas_idx", using: :btree
  add_index "albaran_lineas", ["producto_id"], name: "albaran_lineas_producto_idx", using: :btree

  create_table "albarans", force: :cascade do |t|
    t.string   "codigo",           limit: 255
    t.date     "fecha"
    t.boolean  "cerrado",                      default: false
    t.integer  "proveedor_id",     limit: 4
    t.integer  "cliente_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deposito",                     default: false
    t.date     "fecha_devolucion"
    t.integer  "factura_id",       limit: 4
  end

  add_index "albarans", ["factura_id"], name: "albarans_factura_idx", using: :btree
  add_index "albarans", ["proveedor_id", "cliente_id"], name: "albarans_idx", using: :btree

  create_table "almacenes", force: :cascade do |t|
    t.string   "nombre",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "autor", force: :cascade do |t|
    t.string   "nombre",     limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "autor_x_producto", force: :cascade do |t|
    t.integer  "autor_id",    limit: 4,   null: false
    t.integer  "producto_id", limit: 4,   null: false
    t.string   "rol",         limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "autor_x_producto", ["producto_id", "autor_id"], name: "autor_x_producto_idx", using: :btree

  create_table "avisos", force: :cascade do |t|
    t.string   "mensaje",    limit: 255,                null: false
    t.integer  "criticidad", limit: 4,   default: 1
    t.boolean  "visible",                default: true
    t.string   "url",        limit: 255
    t.string   "objeto",     limit: 255,                null: false
    t.integer  "objeto_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "caja", force: :cascade do |t|
    t.datetime "fecha_hora",                                      null: false
    t.decimal  "importe",                 precision: 8, scale: 2, null: false
    t.string   "comentarios", limit: 255
    t.boolean  "cierre_caja"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campos", force: :cascade do |t|
    t.string   "nombre",     limit: 255
    t.string   "tipo",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clientes", force: :cascade do |t|
    t.string   "nombre",            limit: 255
    t.integer  "descuento",         limit: 4,                           default: 0
    t.string   "email",             limit: 255
    t.string   "cif",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credito",                       precision: 8, scale: 2
    t.string   "direccion",         limit: 255
    t.string   "cp",                limit: 255
    t.decimal  "credito_acumulado",             precision: 8, scale: 2, default: 0.0
  end

  create_table "configuracion", force: :cascade do |t|
    t.string   "nombre_param", limit: 255
    t.string   "valor_param",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "editable",                 default: true
  end

  create_table "editorial", force: :cascade do |t|
    t.string   "nombre",     limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "facturas", force: :cascade do |t|
    t.date     "fecha",                                                                 null: false
    t.string   "codigo",            limit: 255,                                         null: false
    t.decimal  "importe",                       precision: 8, scale: 2,                 null: false
    t.boolean  "pagado",                                                default: false
    t.boolean  "metalico",                                              default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "proveedor_id",      limit: 4
    t.integer  "valor_iva",         limit: 4
    t.integer  "valor_irpf",        limit: 4
    t.decimal  "importe_base",                  precision: 8, scale: 2
    t.date     "fecha_vencimiento"
  end

  add_index "facturas", ["proveedor_id"], name: "factura_idx", using: :btree

  create_table "familias", force: :cascade do |t|
    t.string   "nombre",         limit: 255
    t.integer  "iva_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "acumulable",     limit: 4,   default: 0
    t.boolean  "sincroniza_web",             default: false, null: false
  end

  create_table "forma_pagos", force: :cascade do |t|
    t.string   "nombre",     limit: 255
    t.boolean  "caja",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ivas", force: :cascade do |t|
    t.string   "nombre",     limit: 255
    t.integer  "valor",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_sincronizacion_web", force: :cascade do |t|
    t.string   "elemento_type", limit: 255,                 null: false
    t.boolean  "status_ok",                 default: false, null: false
    t.integer  "actualizados",  limit: 4,   default: 0,     null: false
    t.integer  "eliminados",    limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "materia", force: :cascade do |t|
    t.string   "nombre",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "valor_defecto",             default: false, null: false
    t.integer  "familia_id",    limit: 4,                   null: false
  end

  create_table "pagos", force: :cascade do |t|
    t.decimal  "importe",                 precision: 8, scale: 2, null: false
    t.datetime "fecha",                                           null: false
    t.integer  "factura_id",    limit: 4
    t.integer  "forma_pago_id", limit: 4,                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "producto_editorial_x_almacenes", force: :cascade do |t|
    t.integer  "producto_editorial_id", limit: 4
    t.integer  "almacen_id",            limit: 4
    t.integer  "cantidad",              limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productos", force: :cascade do |t|
    t.string   "codigo",              limit: 255
    t.string   "nombre",              limit: 255
    t.string   "anno",                limit: 255
    t.text     "descripcion",         limit: 65535
    t.string   "url_imagen",          limit: 255
    t.decimal  "precio",                            precision: 8, scale: 2,             null: false
    t.integer  "cantidad",            limit: 4,                             default: 0
    t.integer  "familia_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "materia_id",          limit: 4
    t.integer  "editorial_id",        limit: 4
    t.string   "imagen_file_name",    limit: 255
    t.string   "imagen_content_type", limit: 255
    t.integer  "imagen_file_size",    limit: 4
    t.datetime "imagen_updated_at"
  end

  create_table "productos_editorial", force: :cascade do |t|
    t.integer  "producto_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "productos_editorial", ["producto_id"], name: "fk_rails_a12a0037b1", using: :btree

  create_table "proveedors", force: :cascade do |t|
    t.string   "nombre",     limit: 255
    t.string   "direccion",  limit: 255
    t.string   "email",      limit: 255
    t.string   "telefono",   limit: 255
    t.string   "contacto",   limit: 255
    t.integer  "descuento",  limit: 4,   default: 0
    t.string   "cif",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relacion_web", force: :cascade do |t|
    t.string   "elemento_type", limit: 255,                 null: false
    t.integer  "elemento_id",   limit: 4,                   null: false
    t.integer  "nid",           limit: 4,                   null: false
    t.boolean  "eliminar",                  default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "relacion_web", ["elemento_id", "elemento_type"], name: "index_relacion_web_on_elemento_id_and_elemento_type", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,        null: false
    t.text     "data",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,     null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "acceso_caja",                        default: true
    t.boolean  "acceso_productos",                   default: true
    t.boolean  "acceso_tesoreria",                   default: false
    t.boolean  "acceso_distribuidora",               default: false
    t.boolean  "acceso_admin",                       default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  add_foreign_key "productos_editorial", "productos"
end

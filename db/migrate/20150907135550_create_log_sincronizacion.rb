class CreateLogSincronizacion < ActiveRecord::Migration
  def up
    # Crea la tabla
    create_table :log_sincronizacion_web, force: true do |t|
      t.string   :elemento_type, null: false
      t.boolean  :status_ok, null: false, default: false
      t.integer  :actualizados, null: false, default: 0
      t.integer  :eliminados, null: false, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :log_sincronizacion_web
  end
end

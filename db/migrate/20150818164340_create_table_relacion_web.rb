class CreateTableRelacionWeb < ActiveRecord::Migration
  def up
    create_table :relacion_web, force: true do |t|
      t.string  :elemento_type, null: false
      t.integer :elemento_id, null: false
      t.integer :nid, null: false
      t.boolean :eliminar, null: false, default: false

      t.timestamps
    end
    add_index :relacion_web, [:elemento_id, :elemento_type]
  end

  def down
    drop_table :relacion_web
  end
end

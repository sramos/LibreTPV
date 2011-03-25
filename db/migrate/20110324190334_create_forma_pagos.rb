class CreateFormaPagos < ActiveRecord::Migration
  def self.up
    create_table :forma_pagos do |t|
      t.string :nombre
      t.boolean :caja, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :medio_pagos
  end
end

class CreateFormaPagos < ActiveRecord::Migration
  def self.up
    create_table :forma_pagos do |t|
      t.string :nombre

      t.timestamps
    end
  end

  def self.down
    drop_table :medio_pagos
  end
end

class CheckInvoicesPayment < ActiveRecord::Migration
  def self.up
    Factura.all.each do |f|
      if f.pago_pendiente == 0
        f.pagado = true
        f.save
      end
    end
  end

  def self.down
  end
end

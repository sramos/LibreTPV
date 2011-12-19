class Avisos < ActiveRecord::Base

  
  # Metodos incluidos a la clase 
  class << self
    def activos(visible=true)
      Avisos.all :conditions => { :visible => visible }
    end
  end

end

module CompatibilityHelper

  # Sustituye al observe_field de prototype
  # https://apidock.com/rails/ActionView/Helpers/PrototypeHelper/observe_field
  def observe_field(name, *args)
   options = args.extract_options!.symbolize_keys
   frequency = options[:frequency] || 1
   code  = "$('##{name}').observe_field(#{frequency}, function(){ $('#spinner').show();"
   if options[:url]
     code += "
       var formData = '#{options[:with]}=' + $('##{name}').val();
       $.get('#{url_for(options[:url])}', formData, function(html) {
         $('#spinner').hide();
         $('##{options[:update]}').html(html);
       });"
   else
     code += "alert('Change observed without valid action!');$('#spinner').hide();"
   end
   code += "});"

   javascript_tag do
     raw "$(function() { #{code} });"
   end
  end

  # link_to_remote icono('Cart',{:title => "Ver Productos"}), :url => { :controller => 'albaran_lineas', :action => 'lineas', :albaran_id => objeto.id, :update => "albaran_venta_sub_" + i.to_s }
  def link_to_remote(object, *args)
   options = args.extract_options!.symbolize_keys
   replace_id = options[:url][:update] if options[:url]
   replace_id = options[:update] if replace_id.blank?
   link_to object, url_for(options[:url]), remote: true, "data-update-target" => replace_id
  end

  # NOTA: NO FUNCIONA
  # link_to_function("Código/ISBN", nil, :id => "cambio_a_titulo") do |page|
  #   page.hide 'formulario_seleccion_codigo'
  # end
  def link_to_function(name, *args, &block)
     html_options = args.extract_options!.symbolize_keys

     #puts "***** Nos llegan los params: " + html_options.inspect
     #puts "***** y el bloque de codigo: " + block.inspect

     function = block_given? ? update_page(&block) : args[0] || ''
     onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
     href = html_options[:href] || '#'

     content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end
end


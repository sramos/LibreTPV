
// Activa los selectores chosen
var activaSelectoresChosen = function() {
  $$(".chosen_select").each( function(input) {
    input.setAttribute("data-placeholder","Ningún elemento seleccionado...");
    input.removeClassName('chosen_select');
    new Chosen(input, {width: '100%', allow_single_deselect: true, include_group_label_in_selected: true, no_results_text: "No se ha encontrado" });
  });
}
// Cambia el logo de background
var changeBackground = function() {
  $('logo').setStyle({
    backgroundImage: 'url(<%= ENV["TPV_LOGO"] %>)'
  });
};
function stopRKey(evt) {
  var evt = (evt) ? evt : ((event) ? event : null);
  var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
  if ((evt.keyCode == 13) && (node.id=="formulario_campo_producto_codigo"))  {
    return false;
  }
}

document.onkeypress = stopRKey;

Event.observe(window, 'load', function() {
    var fade=setTimeout("fadeout()",3500);
    var hide=setTimeout("$('mensaje').hide()",4800);
});
function fadeout(){
    new Effect.Opacity("mensaje", {duration:1.5, from:1.0, to:0.0});
}

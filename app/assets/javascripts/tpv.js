
// Activa los selectores chosen
var activaSelectoresChosen = function() {
  $(".chosen_select").each( function() {
    $(this).attr('data-placeholder','Ningún elemento seleccionado...');
    $(this).removeClass('chosen_select');
  });
  $(".chosen_select").chosen()
};
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
};

document.onkeypress = stopRKey;

$(document).ajaxStart(function() {
  $(".spinner").fadeIn('slow');
}).ajaxStop(function() {
    $(".spinner").hide();
});

//Event.observe(window, 'load', function() {
//    var fade=setTimeout("fadeout()",3500);
//    var hide=setTimeout("$('mensaje').hide()",4800);
//});
//function fadeout(){
//    new Effect.Opacity("mensaje", {duration:1.5, from:1.0, to:0.0});
//};

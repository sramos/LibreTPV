
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


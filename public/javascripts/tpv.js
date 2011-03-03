function stopRKey(evt) {
  var evt = (evt) ? evt : ((event) ? event : null);
  var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
  if ((evt.keyCode == 13) && (node.id=="formulario_campo_codigo"))  { 
    return false;
  }
}

document.onkeypress = stopRKey;

LibreTPV::Application.routes.draw do
  root :to => 'albarans#index', :seccion => "caja", :controller => "albarans", :action => "index"
  # map.connect ':seccion/:controller/:action/:id'
  match ':seccion/:controller(/:action(/:id))', via: [:get, :post]
  # map.root :seccion => "caja", :controller => "albarans"
end

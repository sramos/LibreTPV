LibreTPV::Application.routes.draw do
  devise_for :users
  root to: 'inicio#index', seccion: "inicio", controller: "inicio", action: "index"
  #root to: 'albarans#index', seccion: "caja", controller: "albarans", action: "index"
  match ':seccion/:controller(/:action(/:id))', via: [:get, :post, :put, :delete, :patch]
end

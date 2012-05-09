TestApp::Application.routes.draw do
  
  root :to => 'home#index'
  
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signout' => 'sessions#destroy'
  match '/signin' => 'sessions#new'

end

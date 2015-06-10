Rails.application.routes.draw do
  resources :expression_values
  resources :type_of_values
  resources :meta_experiments
  resources :gene_sets
  resources :genes
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'expression_values/gene/:gene_id' => 'expression_values#gene'
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :species
  resources :studies
  resources :varieties
  resources :tissues
  resources :experiments
  resources :experiment_groups

  
end

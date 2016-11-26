Rails.application.routes.draw do
  get 'site/receiveAjax' => 'site#receiveAjax'
  
  get 'spreadsheets/receiveAjaxSpreadsheet' => 'spreadsheets#receiveAjaxSpreadsheet'

  get 'cats/new'

  post 'cats/create'

  delete 'cats/destroy'

  get 'spreadsheets/index'

  get 'spreadsheets/new'

  post 'spreadsheets/create'

  delete 'spreadsheets/destroy'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  get 'CSV.csv', to: 'site#studentOutput', as: :download
  get 'formF_3.csv', to: 'site#formF_3', as: :formF_3
  get 'formF_4.csv', to: 'site#formF_4', as: :formF_4
  get 'formJ_1.csv', to: 'site#formJ_1', as: :formJ_1
  get 'formJ_2.csv', to: 'site#formJ_2', as: :formJ_2
  get 'formI_1.csv', to: 'site#formI_1', as: :formI_1
  get 'formI_2.csv', to: 'site#formI_2', as: :formI_2
  get 'formM_1.csv', to: 'site#formM_1', as: :formM_1
  get 'formM_2.csv', to: 'site#formM_2', as: :formM_2
  get 'formE_1.csv', to: 'site#formE_1', as: :formE_1
  get 'formE_2.csv', to: 'site#formE_2', as: :formE_2
  get 'studentManual.csv', to: 'site#studentManual', as: :studentManual
  get 'output.csv', to: 'site#output', as: :output
   
  # You can have the root of your site routed with "root"
  #root 'movies#index'
  get 'site/index'
  get 'site/selectStudentOrFaculty'
  get 'site/facultyFilterSelection'
  get 'site/studentFilterSelection'
  get 'site/facultyOutput'
  post 'site/studentOutput'
  post 'site/saveQuery'
  get 'site/studentOutput'
  resources :spreadsheets, only: [:index, :new, :create, :destroy]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'site#index'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  #resources :movies
  
  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Rails.application.routes.draw do
  root to: 'homepage#index'

  devise_for :users
  blacklight_for :catalog
  Hydra::BatchEdit.add_routes(self)

  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
end

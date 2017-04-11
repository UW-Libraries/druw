Rails.application.routes.draw do
  # static pages have to be at the top now in order to override the existing about page
  %w(about collection_policy help faq privacy protected_info terms_of_deposit terms_of_use withdrawal).each do |action|
      get action, controller: 'static', action: action, as: action
  end

  Hydra::BatchEdit.add_routes(self)
  mount Qa::Engine => '/authorities'

  mount Blacklight::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  mount Sufia::Engine, at: '/'

  mount CurationConcerns::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'sufia/homepage#index'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

# app/presenters/my_collection_presenter.rb
class MyCollectionPresenter < Sufia::CollectionPresenter
  self.model_class = ::Collection
  self.terms = [:title, :total_items, :size, :resource_type, :description, :complex_creators, :contributor,
                :tag, :rights, :publisher, :date_created, :subject, :language, :grant_award_number, :identifier,
                :based_near, :dec_latitude, :dec_longitude, :related_url, :accrual_method, :accrual_periodicity, 
                :accrual_policy, :license]
end

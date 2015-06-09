# app/presenters/my_collection_presenter.rb
class MyCollectionPresenter < Sufia::CollectionPresenter
  self.model_class = ::Collection
  self.terms = [:title, :total_items, :size, :resource_type, :description, :creator, :contributor,
                :tag, :rights, :publisher, :date_created, :subject, :language, :identifier,
                :based_near, :related_url, :accrual_periodicity, :accrual_policy, :license]
end

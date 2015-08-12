# app/presenters/my_collection_presenter.rb
class MyCollectionPresenter < Sufia::CollectionPresenter
  self.model_class = ::Collection
  self.terms = [:title, :total_items, :size, :resource_type, :creator, :description, :abstract, 
                :contributor, :tag, :subject, :rights, :license, :publisher, 
                :date_created, :other_date, :temporal, :language, :grant_award_number, :identifier,
                :based_near, :dec_latitude, :dec_longitude, :related_url, :accrual_method, 
                :accrual_periodicity, :accrual_policy, :toc]
end

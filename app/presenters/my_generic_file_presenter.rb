class MyGenericFilePresenter < Sufia::GenericFilePresenter
  self.terms = [:resource_type, :title, :complex_creators, :contributor, :description,
    :tag, :rights, :publisher, :date_created, :subject, :language,
    :identifier, :based_near, :related_url, :alternative, :accrual_policy]
end

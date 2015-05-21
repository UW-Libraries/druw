class MyGenericFilePresenter < Sufia::GenericFilePresenter
  self.terms = [:resource_type, :title, :creator, :contributor, :description,
    :tag, :rights, :publisher, :date_created, :subject, :language,
    :identifier, :based_near, :related_url, :alternative, :accrual_periodicity, :accrual_policy, :license]
end

class MyGenericFilePresenter < Sufia::GenericFilePresenter
  self.terms = [:resource_type, :title, :complex_creators, :contributor, :description,
    :tag, :rights, :publisher, :date_created, :subject, :language,
    :grant_award_number, :identifier, :based_near, :dec_latitude, :dec_longitude, :related_url, :alternative, :license]
end

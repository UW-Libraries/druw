class MyGenericFilePresenter < Sufia::GenericFilePresenter
  self.terms = [:resource_type, :title, :alternative, :creator, :contributor, :description, :abstract,
    :tag, :subject, :rights, :license, :publisher, :date_created, :other_date, :temporal, :language,
    :grant_award_number, :identifier, :based_near, :dec_latitude, :dec_longitude, 
    :related_url, :toc ]
end

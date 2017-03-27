class WorkPresenter < Sufia::WorkShowPresenter
  delegate :doi, to: :solr_document
end

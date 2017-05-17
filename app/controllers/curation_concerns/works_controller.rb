# Generated via
#  `rails generate curation_concerns:work Work`

module CurationConcerns
  class WorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = Work
    self.show_presenter = WorkPresenter

    def attributes_for_actor
      attributes = super
      if params[:makedoi]
        attributes[:doi] = "DUMMY"
      end
      attributes
    end
  end
end

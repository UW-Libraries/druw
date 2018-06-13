# Generated via
#  `rails generate hyrax:work TechnicalReport`
module Hyrax
  # Generated controller for TechnicalReport
  class TechnicalReportsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::TechnicalReport

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TechnicalReportPresenter
  end
end

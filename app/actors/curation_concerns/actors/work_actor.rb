# Generated via
#  `rails generate curation_concerns:work Work`
module CurationConcerns
  module Actors
    class WorkActor < CurationConcerns::Actors::BaseActor
      def create(attributes)
        unless ENV['EZID_USER'] and ENV['EZID_USER'].empty?
          Rails.logger.info "Minting DOI [" + ENV['EZID_USER'] + "]"
          shoulder = "doi:10.5072/FK2" # test shoulder
          metadata = Ezid::Metadata.new.tap do |md|
            md.datacite_title = attributes['title'].first
            md.datacite_publisher = "University of Washington" 
            md.datacite_publicationyear = Date.today.year.to_s
            md.datacite_resourcetype = "Dataset"
            md.datacite_creator = attributes['creator'].first
            #md.target = Rails.application.routes.url_helpers.curation_concerns_generic_work_url(id: work.id)
          end
          #server_status = Ezid::Client.new.server_status.up? ? "up" : "down"
          begin
            identifier = Ezid::Identifier.mint shoulder, metadata
            attributes['doi'] = identifier.id 
          rescue Ezid::Error
            Rails.logger.error "Problem connection to EZID service" 
          end
        end
        super
      end
    end
  end
end

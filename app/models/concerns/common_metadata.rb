module CommonMetadata
  extend ActiveSupport::Concern

  # Set up a bunch of MARC Relator codes as contributors
  #CONTRIBUTORS = {}
  #::RDF::Vocab::MARCRelators.map do |term|
  #  CONTRIBUTORS[term.attributes[:label].parameterize.underscore.to_sym] = term.to_uri
  #end
  #CONTRIBUTORS.merge!({ contributor: ::RDF::DC.contributor })

  included do
    property :alternative, predicate: ::RDF::Vocab::DC.alternative do |index|
      index.as :stored_searchable
    end

    property :license, predicate: ::RDF::Vocab::DC.license do |index|
      index.as :stored_searchable
    end
   
    property :grant_award_number, predicate: ::RDF::URI('http://purl.org/eprint/terms/grantNumber') do |index|
      index.as :stored_searchable
    end
    has_and_belongs_to_many :complex_creators, predicate: ::RDF::Vocab::DC.creator, class_name: 'ComplexCreator'

    #CONTRIBUTORS.each do |field_name, predicate|
    #  property field_name, predicate: predicate, class_name: Agent do |index|
    #    index.as :stored_searchable, :facetable
    #  end
    #end

    accepts_nested_attributes_for :complex_creators, allow_destroy: true

    #CONTRIBUTORS.keys.each do |relator|
    #  accepts_nested_attributes_for relator
    #end
  end
end
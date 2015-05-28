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

    property :accrual_policy, predicate: ::RDF::Vocab::DC.accrualPolicy do |index|
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

class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :accrual_periodicity, predicate: ::RDF::DC.Frequency
  property :accrual_policy, predicate: ::RDF::DC.Policy
  property :alternative, predicate: ::RDF::DC.alternative
  property :license, predicate: ::RDF::DC.license, multiple: false
end

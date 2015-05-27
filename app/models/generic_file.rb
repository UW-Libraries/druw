class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :accrual_periodicity, predicate: ::RDF::DC.accrualPeriodicity
  property :accrual_policy, predicate: ::RDF::DC.accrualPolicy
  property :alternative, predicate: ::RDF::DC.alternative
  property :license, predicate: ::RDF::DC.license, multiple: false
end

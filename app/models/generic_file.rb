class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :alternative, predicate: ::RDF::DC.alternative
  property :accrual_policy, predicate: ::RDF::DC.Policy
end

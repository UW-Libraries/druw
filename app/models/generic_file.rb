class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  property :alternative, predicate: ::RDF::DC.alternative
end

class Agent < ActiveFedora::Base
  type ::RDF::DC.Agent

  property :agent_name, predicate: ::RDF::RDFS.label do |index|
    index.as :stored_searchable
  end
  property :preferred_name, predicate: ::RDF::SKOS.prefLabel do |index|
    index.as :stored_searchable
  end
  property :same_as, predicate: ::RDF::OWL.sameAs
  property :identified_by_authority, predicate: ::RDF::Vocab::MADS.isIdentifiedByAuthority
end

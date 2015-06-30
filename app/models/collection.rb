class Collection < Sufia::Collection
  # Use Sufia's collection class, else we pick up HydraCollections's class
  include CommonMetadata

  property :accrual_method, predicate: ::RDF::DC.accrualMethod
  property :accrual_periodicity, predicate: ::RDF::DC.accrualPeriodicity
  property :accrual_policy, predicate: ::RDF::DC.accrualPolicy
end

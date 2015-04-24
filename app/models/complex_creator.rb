class ComplexCreator < Agent
  has_many :generic_files, inverse_of: :complex_creators, class_name: 'GenericFile'
end

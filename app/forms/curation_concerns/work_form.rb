# Generated via
#  `rails generate curation_concerns:work Work`
module CurationConcerns
  class WorkForm < CurationConcerns::Forms::WorkForm
    self.model_class = ::Work

    self.terms += [:resource_type, :doi]

  end
end

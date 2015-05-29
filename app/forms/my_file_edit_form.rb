class MyFileEditForm < MyGenericFilePresenter
  include HydraEditor::Form
  include HydraEditor::Form::Permissions

  self.required_fields = [:title, :complex_creators, :tag, :rights, :license]

  protected

    def self.build_permitted_params
      permitted = super
      permitted.delete({ complex_creators: [] })
      permitted << { complex_creators_attributes: complex_creators_params }
      permitted
    end

    def self.complex_creators_params
      [
        :id,
        :_destroy,
        {
          agent_name: [],
          preferred_name: [],
          same_as: [],
          identified_by_authority: []
        }
      ]
    end

    # Override HydraEditor::Form to treat nested attbriutes accordingly
    def initialize_field(key)
      if reflection = model_class.reflect_on_association(key)
        raise ArgumentError, "Association ''#{key}'' is not a collection" unless reflection.collection?
        build_association(key)
      else
        super
      end
    end

  private

    def build_association(key)
      association = model.send(key)
      if association.empty?
        self[key] = Array(association.build)
      else
        association.build
        self[key] = association
      end
    end

end

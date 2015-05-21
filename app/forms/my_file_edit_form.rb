class MyFileEditForm < MyGenericFilePresenter
  include HydraEditor::Form
  include HydraEditor::Form::Permissions

  self.required_fields = [:title, :creator, :tag, :rights, :license] 
end

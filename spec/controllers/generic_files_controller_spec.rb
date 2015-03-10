describe GenericFilesController do
  it 'has the right presenter' do
    expect(subject.presenter_class).to eq(MyGenericFilePresenter)
  end
  it 'has the right edit form' do
    expect(subject.edit_form_class).to eq(MyFileEditForm)
  end
end

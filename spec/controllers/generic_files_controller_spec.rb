describe GenericFilesController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.create(:odegaard) }
  before { sign_in user }

  it 'uses the overridden presenter' do
    expect(subject.presenter_class).to eq(MyGenericFilePresenter)
  end

  it 'uses the overridden form' do
    expect(subject.edit_form_class).to eq(MyFileEditForm)
  end

  describe '#update' do
    let(:generic_file) do
      GenericFile.create { |f| f.apply_depositor_metadata(user) }
    end

    context 'with an alternative title' do
      let(:generic_file) { GenericFile.create { |f| f.apply_depositor_metadata(user.user_key) } }
      let(:alt_title) { ['Totally awesome'] }
      it 'adds an alternative title' do
        post :update, id: generic_file, generic_file: { alternative: alt_title }
        expect(generic_file.reload.alternative).to eq alt_title
      end
    end

    context 'with a license' do
      let(:generic_file) { GenericFile.create { |f| f.apply_depositor_metadata(user.user_key) } }
      let(:license) { ['Have at it'] }
      it 'adds a license' do
        post :update, id: generic_file, generic_file: { license: license }
        expect(generic_file.reload.license).to eq license
      end
    end
  end
end

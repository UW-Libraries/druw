describe CollectionsController, type: :controller do
  routes { Hydra::Collections::Engine.routes }
  let(:user) { FactoryGirl.create(:odegaard) }
  before { sign_in user }

  it 'uses the overridden presenter' do
    expect(subject.presenter_class).to eq(MyCollectionPresenter)
  end

  it 'uses the overridden form' do
    expect(subject.edit_form_class).to eq(MyCollectionEditForm)
  end

  describe '#update' do
    let(:title) { 'Best Collection Ever' }
    let(:collection) { Collection.create(title: title) { |f| f.apply_depositor_metadata(user.user_key) } }

    context 'with an accrual policy' do
      let(:policy) { ['This thing is allow to accrue stuff.'] }
      it 'adds an accrual policy' do
        post :update, id: collection, collection: { accrual_policy: policy }
        expect(collection.reload.accrual_policy).to eq policy
      end
    end

    context 'with an accrual periodicity' do
      let(:periodicity) { ['Accrues stuff every seventeen fortnights'] }
      it 'adds an accrual periodicity' do
        post :update, id: collection, collection: { accrual_periodicity: periodicity }
        expect(collection.reload.accrual_periodicity).to eq periodicity
      end
    end

    context 'with an alternative title' do
      let(:alt_title) { ['Totally awesome'] }
      it 'adds an alternative title' do
        post :update, id: collection, collection: { alternative: alt_title }
        expect(collection.reload.alternative).to eq alt_title
      end
    end

    context 'with a license' do
      let(:license) { ['Have at it'] }
      it 'adds a license' do
        post :update, id: collection, collection: { license: license }
        expect(collection.reload.license).to eq license
      end
    end
  end
end

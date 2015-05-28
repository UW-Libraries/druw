require 'rails_helper'

describe GenericFilesController do
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

    context 'with added complex_creators' do
      let(:attributes) do
        {
          complex_creators_attributes: [
            { agent_name: ["Foo Bar"] },
            { agent_name: ["Baz Quux"], preferred_name: ['B.Q.'] },
            { agent_name: ["Fuzz Ball"] }
          ]
        }
      end
      before do
        post :update, id: generic_file, generic_file: attributes
      end
      subject { generic_file.reload }
      it 'creates ComplexCreator instances' do
        expect(ComplexCreator.count).to eq 3
      end
      it 'has three complex_creators' do
        expect(subject.complex_creators.count).to eq 3
      end
      it 'assigns agents to the complex_creators field' do
        complex_creators = subject.complex_creators
        agent_names = complex_creators.map(&:agent_name)
        preferred_names  = complex_creators.map(&:preferred_name)
        expect(agent_names).to include ['Foo Bar']
        expect(agent_names).to include ['Baz Quux']
        expect(agent_names).to include ['Fuzz Ball']
        expect(preferred_names).to include ['B.Q.']
      end
    end

    context 'with an alternative title' do
      let(:generic_file) { GenericFile.create { |f| f.apply_depositor_metadata(user.user_key) } }
      let(:alt_title) { ['Totally awesome'] }
      it 'adds an alternative title' do
        post :update, id: generic_file, generic_file: { alternative: alt_title }
        expect(generic_file.reload.alternative).to eq alt_title
      end
    end

    context 'with an accrual policy' do
      let(:generic_file) { GenericFile.create { |f| f.apply_depositor_metadata(user.user_key) } }
      let(:policy) { ['This thing is allow to accrue stuff.'] }
      it 'adds an accrual policy' do
        post :update, id: generic_file, generic_file: { accrual_policy: policy }
        expect(generic_file.reload.accrual_policy).to eq policy
      end
    end
  end
end

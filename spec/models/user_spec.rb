describe User, type: :model do
  it { is_expected.to respond_to(:email) }

  describe '#to_s' do
    let(:user) { FactoryGirl.create(:odegaard) }
    subject { user.to_s }
    it { is_expected.to eq user.email }
  end
end

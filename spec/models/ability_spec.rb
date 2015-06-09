require 'cancan/matchers'

describe Ability, type: :model do
  describe 'an admin user' do
    let(:user) { FactoryGirl.create(:odegaard) }
    before { allow(user).to receive(:admin?).and_return(true) }
    subject { Ability.new(user) }
    it { is_expected.to be_able_to(:create, TinymceAsset) }
    it { is_expected.to be_able_to(:create, ContentBlock) }
    it { is_expected.to be_able_to(:update, ContentBlock) }
  end

  describe 'a plebeian user' do
    let(:user) { FactoryGirl.create(:gerberding) }
    before { allow(user).to receive(:admin?).and_return(false) }
    subject { Ability.new(user) }
    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:create, ContentBlock) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }
  end
end

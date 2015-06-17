describe MyCollectionEditForm do
  describe '.terms' do
    subject { described_class.terms }
    it { is_expected.to include(:license) }
    it { is_expected.to include(:grant_award_number) }
    it { is_expected.to include(:complex_creators) }
  end
end
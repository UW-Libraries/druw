describe MyCollectionPresenter do
  describe 'terms' do
   subject { described_class.terms }
	it { is_expected.to include(:accrual_policy) }
	it { is_expected.to include(:license) }
	it { is_expected.to include(:accrual_periodicity) }
	it { is_expected.to include(:grant_award_number) }	
  end
end

describe MyBatchEditForm do
  describe 'terms' do 
    subject { described_class.terms }  
    it { is_expected.to include(:alternative) }
    it { is_expected.to include(:license) }
    it { is_expected.to include(:complex_creators) }
    it { is_expected.to include(:grant_award_number) }
  end
end
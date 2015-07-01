describe GenericFile do
  it { is_expected.to respond_to(:alternative) }
  it { is_expected.to respond_to(:license) }
  it { is_expected.to respond_to(:grant_award_number) }
  it { is_expected.to respond_to(:complex_creators) }
  it { is_expected.to respond_to(:dec_latitude) }
  it { is_expected.to respond_to(:dec_longitude) }
  it { is_expected.to respond_to(:other_date) }
  it { is_expected.to respond_to(:temporal) }
  it { is_expected.to respond_to(:abstract) }
 
 describe 'complex creators' do
    subject do
      described_class.create(title: ['title1']) do |gf|
        gf.apply_depositor_metadata('dpt')
        gf.complex_creators_attributes = [{agent_name: agent_name}]
      end
    end
    let(:agent_name) { ['Bob Smith'] }
    it 'has a single complex_creator' do
      expect(subject.complex_creators.count).to eq 1
      expect(subject.complex_creators.first.agent_name).to eq agent_name
    end
  end
end

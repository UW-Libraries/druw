describe MyFileEditForm do
  describe '.terms' do
    subject { described_class.terms }
    it { is_expected.to include(:alternative) }
    it { is_expected.to include(:license) }
    it { is_expected.to include(:complex_creators) }
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }
    let(:complex_creator_params) {
      [
        :id,
        :_destroy,
        {
          agent_name: [],
          preferred_name: [],
          same_as: [],
          identified_by_authority: []
        }
      ]
    }
    it { is_expected.to include(complex_creators_attributes: complex_creator_params) }
    it { is_expected.not_to include(complex_creators: []) }
  end

  describe '.initialize_field' do
    context 'with complex creators' do
      let(:creator1) { ComplexCreator.create(agent_name: ['Creator One']) }
      let(:creator2) { ComplexCreator.create(agent_name: ['Creator Two']) }
      let(:generic_file) do
        GenericFile.create(complex_creators: [creator1, creator2]) do |file|
          file.apply_depositor_metadata('foo')
        end
      end
      subject { described_class.new(generic_file) }
      it 'includes creators' do
        expect(subject[:complex_creators]).to include(creator1, creator2)
      end
    end

    context 'without complex creators' do
      let(:generic_file) do
        GenericFile.create do |file|
          file.apply_depositor_metadata('foo')
        end
      end
      subject { described_class.new(generic_file) }
      it 'does not include creators' do
        expect(subject[:complex_creators]).to include ComplexCreator
      end
    end
  end
end

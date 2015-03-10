describe MyBatchEditForm do
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
end

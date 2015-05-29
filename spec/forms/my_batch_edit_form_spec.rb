describe MyBatchEditForm do
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
  it 'includes license in its terms' do
    expect(described_class.terms).to include(:license)
  end
  it 'includes complex creators in its terms' do
    expect(described_class.terms).to include(:complex_creators)
  end
end

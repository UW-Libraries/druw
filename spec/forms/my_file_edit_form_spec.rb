describe MyFileEditForm do
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
  it 'includes accrualPolicy in its terms' do
    expect(described_class.terms).to include(:accrual_policy)
  end
  it 'includes complex creators in its terms' do
    expect(described_class.terms).to include(:complex_creators)
  end
end

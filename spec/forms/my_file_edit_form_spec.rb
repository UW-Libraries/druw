describe MyFileEditForm do
  it 'includes accrualPeriodicity in its terms' do
    expect(described_class.terms).to include(:accrual_periodicity)
  end
  it 'includes accrualPolicy in its terms' do
    expect(described_class.terms).to include(:accrual_policy)
  end
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
end

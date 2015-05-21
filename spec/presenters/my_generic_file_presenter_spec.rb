describe MyGenericFilePresenter do
  it 'includes accrual_periodicity in its terms' do
    expect(described_class.terms).to include(:accrual_periodicity)
  end
  it 'includes accrual_policy in its terms' do
    expect(described_class.terms).to include(:accrual_policy)
  end
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
  it 'includes license in its terms' do
    expect(described_class.terms).to include(:license)
  end
end

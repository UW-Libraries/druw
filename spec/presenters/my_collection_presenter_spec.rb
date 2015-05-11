describe MyCollectionPresenter do
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:accrual_policy)
  end
  it 'includes license in its terms' do
    expect(described_class.terms).to include(:license)
  end
  it 'includes complex creators in its terms' do
    expect(described_class.terms).to include(:accrual_periodicity)
  end
  it 'includes complex creators in its terms' do
    expect(described_class.terms).to include(:grant_award_number)
  end
end

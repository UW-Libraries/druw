describe MyBatchEditForm do
  it 'includes alternative in its terms' do
    expect(described_class.terms).to include(:alternative)
  end
  it 'includes accrual_policy in its terms' do
    expect(described_class.terms).to include(:accrual_policy)
  end
end

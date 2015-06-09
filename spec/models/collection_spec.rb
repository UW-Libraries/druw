describe Collection do
  it { is_expected.to respond_to(:bytes) }
  it { is_expected.to respond_to(:accrual_periodicity) }
  it { is_expected.to respond_to(:accrual_policy) }
  it { is_expected.to respond_to(:license) }
  it { is_expected.to respond_to(:alternative) }
end

describe GenericFile do
  it { is_expected.to respond_to(:accrual_periodicity) }
  it { is_expected.to respond_to(:accrual_policy) }
  it { is_expected.to respond_to(:alternative) }
  it { is_expected.to respond_to(:license) }
end

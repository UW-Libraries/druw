describe Collection do
  it { is_expected.to respond_to(:bytes) }
  it { is_expected.to respond_to(:accrual_periodicity) }
  it { is_expected.to respond_to(:accrual_policy) }
  it { is_expected.to respond_to(:license) }
  it { is_expected.to respond_to(:grant_award_number) }
  it { is_expected.to respond_to(:alternative) }
  it { is_expected.to respond_to(:dec_latitude) }
  it { is_expected.to respond_to(:dec_longitude) }
end

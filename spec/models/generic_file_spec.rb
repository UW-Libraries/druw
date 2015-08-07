describe GenericFile do
  it { is_expected.to respond_to(:alternative) }
  it { is_expected.to respond_to(:license) }
  it { is_expected.to respond_to(:grant_award_number) }
  it { is_expected.to respond_to(:dec_latitude) }
  it { is_expected.to respond_to(:dec_longitude) }
  it { is_expected.to respond_to(:other_date) }
  it { is_expected.to respond_to(:temporal) }
  it { is_expected.to respond_to(:abstract) }
  it { is_expected.to respond_to(:toc) }
end

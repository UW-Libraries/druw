require 'rails_helper'

describe Agent do
  it { is_expected.to respond_to(:agent_name) }
  it { is_expected.to respond_to(:preferred_name) }
  it { is_expected.to respond_to(:same_as) }
  it { is_expected.to respond_to(:identified_by_authority) }
end

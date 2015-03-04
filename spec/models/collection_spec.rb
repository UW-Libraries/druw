require 'rails_helper'

describe Collection do
  it { is_expected.to respond_to(:bytes) }
end

# Generated via
#  `rails generate curation_concerns:work Work`
require 'rails_helper'

RSpec.describe Work do
  describe "metadata" do
    it "has descriptive metadata" do
      expect(subject).to respond_to(:doi)
    end
  end
end


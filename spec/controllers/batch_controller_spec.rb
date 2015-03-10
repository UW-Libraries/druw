require 'rails_helper'

describe BatchController do
  it 'has the right edit form' do
    expect(subject.edit_form_class).to eq(MyBatchEditForm)
  end
end

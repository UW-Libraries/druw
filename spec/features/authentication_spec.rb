require 'rails_helper'

describe 'Authentication', type: :feature do
  let(:user) { FactoryGirl.create(:odegaard) }

  context 'when resetting your password' do
    before  { visit new_user_password_url }

    context 'with an existing user' do
      it 'allows the form to be submitted' do
        fill_in 'Email', with: user.email
        click_button 'Send me reset password instructions'
        expect(page).to have_content('You will receive an email with instructions on how to reset your password in a few minutes')
      end
    end

    context 'with an unregistered email address' do
      let(:bogus_email) { 'allen@example.org' }

      it 'complains about the email address' do
        fill_in 'Email', with: bogus_email
        click_button 'Send me reset password instructions'
        expect(page).to have_content('Email not found')
      end
    end
  end
end

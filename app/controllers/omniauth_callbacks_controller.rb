class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  ## handle omniauth logins from shibboleth
  ## cf https://github.com/toyokazu/omniauth-shibboleth/issues/6
  def shibboleth
    @user = User.from_omniauth(request.env["omniauth.auth"])
    ## capture data about the user from shib
    session['shib_user_data'] = request.env["omniauth.auth"]
    sign_in_and_redirect @user
  end

  ## when shib login fails
  #def failure
  #  ## redirect them to the devise local login page
  #  redirect_to new_local_user_session_path, :notice => "Shibboleth isn't available - local login only"
  #end

end

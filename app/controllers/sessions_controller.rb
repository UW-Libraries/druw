class SessionsController < Devise::SessionsController
  def new
    if Rails.env.production?
      # Automatically use Shibboleth auth
      redirect_to user_shibboleth_omniauth_authorize_path #(:shibboleth)
    else
      # Give user choice of Shibboleth or manual login
      super
    end
  end
end

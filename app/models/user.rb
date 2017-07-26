class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles


  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats



  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :registerable, :omniauthable, :rememberable, :trackable, omniauth_providers: [:shibboleth], authentication_keys: [:email]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  ## allow omniauth (including shibboleth) logins - this will create a local user based on an omniauth/shib login
  ## if they haven't logged in before
  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      #user.provider = auth.provider
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
end

class Ability
  include Hydra::Ability
  include Sufia::Ability

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if admin_user?
  end

  def editor_abilities
    if admin_user?
      can :create, TinymceAsset
      can [:create, :update], ContentBlock
    end
    can :read, ContentBlock
  end

  def admin_user?
    current_user.admin?
  end
end

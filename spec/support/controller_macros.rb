module ControllerMacros
  
  def login_user(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
     sign_in user
     @ability = Ability.new(@user)
     allow(controller).to receive(:current_ability).and_return @ability
     @ability.can :manage, :all
  end
end
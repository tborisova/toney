require 'rails_helper'
require "cancan/matchers"

RSpec.describe Ability, :type => :model do
  
  context 'user' do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @month = FactoryGirl.create(:month, user: @user)
    end

    it 'can manage his months' do
      ability = Ability.new(@user)

      expect(ability).to be_able_to :new, Month
      expect(ability).to be_able_to :manage, @month
      expect(ability).to_not be_able_to :manage, FactoryGirl.create(:month)
    end

    it 'can manage only notes of his months' do
      note1 = FactoryGirl.create(:note, month: @month)

      ability = Ability.new(@user)

      expect(ability).to be_able_to :new, Note
      expect(ability).to be_able_to :manage, note1
      expect(ability).to_not be_able_to :manage, FactoryGirl.create(:note)
    end

  end
end

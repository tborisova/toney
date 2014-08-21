require 'rails_helper'

RSpec.describe Note, :type => :model do

  context 'associations' do

    it { should belong_to :month }
  end
end

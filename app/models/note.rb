class Note# < ActiveRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  field :money, type: Float
  field :title, type: String

  belongs_to :month
end

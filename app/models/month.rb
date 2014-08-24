class Month
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  field :start, type: Date
  field :end, type: Date
  field :money, type: Float

  belongs_to :user
  has_many :notes, dependent: :destroy

  validates_uniqueness_of :start, :end
end

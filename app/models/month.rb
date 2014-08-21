class Month < ActiveRecord::Base
  belongs_to :user
  has_many :notes

  validates_uniqueness_of :start, :end
end

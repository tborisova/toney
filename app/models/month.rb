class Month < ActiveRecord::Base
  belongs_to :user
  has_many :notes

  validates_uniqueness_of :start, :end

  def notes_money
     sum = self.notes.map(&:money).inject{|sum, x| sum + x}
     return 0 unless sum
     return sum
  end
end

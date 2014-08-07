class Month < ActiveRecord::Base
  belongs_to :user
  has_many :notes

  validates_uniqueness_of :start, :end

  def notes_money
    money_notes = self.notes.map(&:money).inject{|sum, x| sum + x}

  end
end

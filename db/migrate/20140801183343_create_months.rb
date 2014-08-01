class CreateMonths < ActiveRecord::Migration
  def change
    create_table :months do |t|
      t.references :user, index: true
      t.date :start
      t.date :end
      t.float :money

      t.timestamps
    end
  end
end

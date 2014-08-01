class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :month, index: true
      t.float :money, :scale => 2
      t.string :title

      t.timestamps
    end
  end
end

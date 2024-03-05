class CreateCardArts < ActiveRecord::Migration[7.1]
  def change
    create_table :card_arts, id: :integer do |t|
      t.belongs_to :card
      t.text :small_path
      t.text :full_path

      t.timestamps
    end
  end
end

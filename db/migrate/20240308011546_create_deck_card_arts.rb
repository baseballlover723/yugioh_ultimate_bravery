class CreateDeckCardArts < ActiveRecord::Migration[7.1]
  def change
    create_table :deck_card_arts, id: false do |t|
      t.belongs_to :deck, null: false, foreign_key: true, type: :uuid
      t.belongs_to :card_art, null: false, foreign_key: true, type: :integer
      t.integer :copies, null: false

      t.index [:deck_id, :card_art_id], unique: true

      t.timestamps
    end
  end
end

class CreateDecks < ActiveRecord::Migration[7.1]
  def change
    create_table :decks, id: :uuid do |t|
      t.text :name
      t.text :format
      t.references :skill_card_art, foreign_key: { to_table: :card_arts }, type: :integer
      t.jsonb :generate_options

      t.timestamps
    end
  end
end

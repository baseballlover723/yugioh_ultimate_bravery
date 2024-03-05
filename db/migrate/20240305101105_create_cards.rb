class CreateCards < ActiveRecord::Migration[7.1]
  def change
    create_table :cards, id: :integer do |t|
      t.text :name, null: false
      t.text :card_type, null: false
      t.text :frame_type, null: false
      t.text :macro_frame_type, null: false
      t.text :race, null: false
      t.text :archetype
      t.text :card_attribute
      t.integer :level
      t.integer :atk
      t.integer :def
      t.integer :scale
      t.boolean :extra_deck, null: false
      t.text :link_markers, null: false, array: true, default: []
      t.text :desc, null: false

      t.timestamps
    end

    add_index :cards, :card_type
    add_index :cards, :frame_type
    add_index :cards, :macro_frame_type
    add_index :cards, :archetype
    add_index :cards, :card_attribute
    add_index :cards, :level
    add_index :cards, :atk
    add_index :cards, :def
    add_index :cards, :scale
    add_index :cards, :extra_deck

  end
end

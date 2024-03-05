# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_05_101115) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_arts", id: :serial, force: :cascade do |t|
    t.bigint "card_id"
    t.text "small_path"
    t.text "full_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_arts_on_card_id"
  end

  create_table "cards", id: :serial, force: :cascade do |t|
    t.text "name", null: false
    t.text "card_type", null: false
    t.text "frame_type", null: false
    t.text "macro_frame_type", null: false
    t.text "race", null: false
    t.text "archetype"
    t.text "card_attribute"
    t.integer "level"
    t.integer "atk"
    t.integer "def"
    t.integer "scale"
    t.boolean "extra_deck", null: false
    t.text "link_markers", default: [], null: false, array: true
    t.text "desc", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archetype"], name: "index_cards_on_archetype"
    t.index ["atk"], name: "index_cards_on_atk"
    t.index ["card_attribute"], name: "index_cards_on_card_attribute"
    t.index ["card_type"], name: "index_cards_on_card_type"
    t.index ["def"], name: "index_cards_on_def"
    t.index ["extra_deck"], name: "index_cards_on_extra_deck"
    t.index ["frame_type"], name: "index_cards_on_frame_type"
    t.index ["level"], name: "index_cards_on_level"
    t.index ["macro_frame_type"], name: "index_cards_on_macro_frame_type"
    t.index ["scale"], name: "index_cards_on_scale"
  end

end

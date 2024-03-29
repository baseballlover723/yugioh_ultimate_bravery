# == Schema Information
#
# Table name: decks
#
#  id                :uuid             not null, primary key
#  format            :text
#  generate_options  :jsonb
#  name              :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  skill_card_art_id :integer
#
# Indexes
#
#  index_decks_on_skill_card_art_id  (skill_card_art_id)
#
# Foreign Keys
#
#  fk_rails_...  (skill_card_art_id => card_arts.id)
#
class Deck < ApplicationRecord
  belongs_to :skill_card_art, optional: true, class_name: "CardArt"
  has_many :deck_card_arts
  has_many :card_arts, through: :deck_card_arts, autosave: false
end

# == Schema Information
#
# Table name: deck_card_arts
#
#  copies      :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  card_art_id :integer          not null
#  deck_id     :uuid             not null
#
# Indexes
#
#  index_deck_card_arts_on_card_art_id              (card_art_id)
#  index_deck_card_arts_on_deck_id                  (deck_id)
#  index_deck_card_arts_on_deck_id_and_card_art_id  (deck_id,card_art_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (card_art_id => card_arts.id)
#  fk_rails_...  (deck_id => decks.id)
#
require "test_helper"

class DeckCardArtTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

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
require "test_helper"

class DeckTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

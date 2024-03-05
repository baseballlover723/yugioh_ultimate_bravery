# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  archetype        :text
#  atk              :integer
#  card_attribute   :text
#  card_type        :text             not null
#  def              :integer
#  desc             :text             not null
#  extra_deck       :boolean          not null
#  frame_type       :text             not null
#  level            :integer
#  link_markers     :text             default([]), not null, is an Array
#  macro_frame_type :text             not null
#  name             :text             not null
#  race             :text             not null
#  scale            :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_cards_on_archetype         (archetype)
#  index_cards_on_atk               (atk)
#  index_cards_on_card_attribute    (card_attribute)
#  index_cards_on_card_type         (card_type)
#  index_cards_on_def               (def)
#  index_cards_on_extra_deck        (extra_deck)
#  index_cards_on_frame_type        (frame_type)
#  index_cards_on_level             (level)
#  index_cards_on_macro_frame_type  (macro_frame_type)
#  index_cards_on_scale             (scale)
#
require "test_helper"

class CardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

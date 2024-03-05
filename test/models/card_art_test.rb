# == Schema Information
#
# Table name: card_arts
#
#  id         :integer          not null, primary key
#  full_path  :text
#  small_path :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  card_id    :bigint
#
# Indexes
#
#  index_card_arts_on_card_id  (card_id)
#
require "test_helper"

class CardArtTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

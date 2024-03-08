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
class Card < ApplicationRecord
  EXTRA_DECK_FRAME_TYPES = Set["fusion", "link", "xyz", "synchro", "fusion_pendulum", "synchro_pendulum", "xyz_pendulum"].freeze
  ATTRIBUTE_NAMES = self.attribute_names - ["created_at", "updated_at"]
  ARRAY_ATTRIBUTE_NAMES = Set["link_markers"]

  has_many :card_arts
  has_many :cards_deck
  has_many :decks, through: :cards_deck

  scope :main_deck, -> {where(extra_deck: false).where.not(frame_type: "skill")}
  scope :extra_deck, -> {where(extra_deck: true).where.not(frame_type: "skill")}
  scope :skill_card, -> {where(frame_type: "skill")}

  def self.translate_ygo_pro_deck_params(card)
    card["frame_type"] = card["frameType"]
    card["card_type"] = card["type"]
    card["link_markers"] = card["linkmarkers"] || []
    card["card_attribute"] = card["attribute"]
    card["level"] = card["linkval"] if card["frame_type"] == "link"
    card["extra_deck"] = EXTRA_DECK_FRAME_TYPES.include?(card["frame_type"])
    card["macro_frame_type"] = calc_macro_frame_type(card["frame_type"])

    card.slice!(*ATTRIBUTE_NAMES)
    ATTRIBUTE_NAMES.each do |name|
      card[name] = ARRAY_ATTRIBUTE_NAMES.include?(name) ? [] : nil if !card.include?(name)
    end

    card
  end

  private

  def self.calc_macro_frame_type(frame_type)
    case frame_type
    when "fusion", "fusion_pendulum"
      "fusion"
    when "synchro", "synchro_pendulum"
      "synchro"
    when "xyz", "xyz_pendulum"
      "xyz"
    when "link"
      "link"
    when "spell"
      "spell"
    when "trap"
      "trap"
    when "effect", "normal", "effect_pendulum", "normal_pendulum", "ritual", "ritual_pendulum"
      "monster"
    when "skill"
      "skill"
    end
  end
end

class Api::V1::DeckController < ApplicationController
  def index
    decks = Deck.includes(skill_card_art: :card, card_arts: :card).all
    render json: decks, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  # TODO validate params and fix defaults
  # should receive count_min and count_max instead of range and then build from there
  def create
    deck = DeckService.generate(extra_deck: {count: 10, fusion: {count: 0..5}, synchro: {count: 0..5}, xyz: {count: 2..4}, link: {count: 1..1}})
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(deck.id)
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  def show
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(params[:id])
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end
end

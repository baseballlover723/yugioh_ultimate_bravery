class Api::V1::DeckController < ApplicationController
  def index
    decks = Deck.includes(skill_card_art: :card, card_arts: :card).all
    render json: decks, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  def create
    deck = DeckService.generate(main_deck: 40..60, extra_deck: 0..15)
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(deck.id)
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  def show
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(params[:id])
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end
end

class Api::V1::DeckController < ApiApplicationController
  @@validator = Api::V1::DeckContract.new

  def index
    decks = Deck.includes(skill_card_art: :card, card_arts: :card).all
    render json: decks, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  def create
    processed_options = @@validator.call(params.to_unsafe_hash)
    return render json: {errors: processed_options.errors.to_h} if processed_options.failure?

    puts "returning: #{processed_options.values.to_h}"
    return render json: {status: "ok", processed_options: processed_options.values.to_h}
    deck = DeckService.generate(processed_options.values.to_h)
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(deck.id)
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end

  def show
    deck = Deck.includes(skill_card_art: :card, card_arts: :card).find(params[:id])
    render json: deck, include: {skill_card_art: {include: :card, except: :card_id}, card_arts: {include: :card, except: :card_id}}, except: :skill_card_art_id
  end
end

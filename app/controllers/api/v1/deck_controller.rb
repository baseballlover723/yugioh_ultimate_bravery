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

  def settings
    last_update, hash, json_str = DeckService.get_settings
    if stale?(etag: hash, last_modified: last_update, public: true)
      render json: json_str
    end
  end

  def update_settings
    last_id = Card.maximum(:id)
    last_id = 999_999_999 if last_id < 1_000_000_000
    last_atk = Card.where(macro_frame_type: "fusion").maximum(:atk)
    last_atk = 9_999 if last_atk < 10_000
    Card.create(id: last_id + 1, card_type: "test_card", desc: "test desc", extra_deck: true,
                frame_type: "test_frame_type", macro_frame_type: "fusion", name: "test_card_#{last_id + 1}",
                race: "test_race", atk: last_atk + 1
    )
    DeckService.refresh_settings_cache
    render json: "ok_update"
  end

  def reset_settings
    Card.where(id: 1_000_000_000..).delete_all
    DeckService.refresh_settings_cache
    render json: "ok_reset"
  end

end

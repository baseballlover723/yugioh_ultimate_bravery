class DeckService
  @@main_deck_cards = Card.main_deck.eager_load(:card_arts).load
  @@extra_deck_cards = Card.extra_deck.eager_load(:card_arts).load
  @@skill_cards = Card.skill_card.eager_load(:card_arts).load

  def self.generate(options)
    deck = Deck.new(generate_options: options)
    numb_main_deck_cards = rand(options[:main_deck])
    numb_extra_deck_cards = rand(options[:extra_deck])

    # puts "main_deck_cards: #{@@main_deck_cards.inspect}"
    # puts "card_arts: #{@@main_deck_cards[0].card_arts.inspect}"
    # puts "card_arts: #{@@main_deck_cards[1].card_arts.inspect}"
    # return nil

    if rand(2) == 1
      deck.skill_card_art_id = @@skill_cards.sample.card_art_ids[0]
    end

    cards = []
    cards.concat(@@main_deck_cards.sample(numb_main_deck_cards).map{|card| [1, card.card_art_ids.sample]})
    cards.concat(@@extra_deck_cards.sample(numb_extra_deck_cards).map{|card| [1, card.card_art_ids.sample]})

    # cards.concat(@@main_deck_cards.sample(numb_main_deck_cards).map{|card| [1, card, rand(card.small_card_art_urls.size)]})
    # cards.concat(@@extra_deck_cards.sample(numb_extra_deck_cards).map{|card| [1, card, rand(card.small_card_art_urls.size)]})

    deck.name = "Deck ##{(Deck.count + 1).to_fs(:delimited)}"
    Deck.transaction do
      deck.save
      DeckCardArt.insert_all(cards.map do |copies, card_art_id|
        {deck_id: deck.id, card_art_id: card_art_id, copies: copies}
      end)
    end

    deck
  end
end
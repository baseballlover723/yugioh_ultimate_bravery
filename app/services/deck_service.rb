class DeckService
  @@main_deck_cards = Card.main_deck.eager_load(:card_arts).load
  @@extra_deck_cards = Card.extra_deck.eager_load(:card_arts).load
  @@skill_cards = Card.skill_card.eager_load(:card_arts).load

  OPTIONS = {
    main_deck: {
      count: nil,
      monster: {
        count: nil,
      },
      spell: {
        count: nil
      },
      trap: {
        count: nil
      }
    },
    extra_deck: {
      count: nil,
      fusion: {
        count: nil,
        level: nil,
        atk: nil,
        def: nil,
        card_attribute: nil,
        card_type: nil
      },
      synchro: {
        count: nil,
        level: nil,
        atk: nil,
        def: nil,
        card_attribute: nil,
        card_type: nil
      },
      xyz: {
        count: nil,
        level: nil,
        atk: nil,
        def: nil,
        card_attribute: nil,
        card_type: nil
      },
      link: {
        count: nil,
        level: nil,
        atk: nil,
        def: nil,
        card_attribute: nil,
        card_type: nil
      }
    }
  }

  def self.generate(**options)
    options.with_defaults!(OPTIONS)
    puts "options: #{options}"
    deck = Deck.new(generate_options: options)

    numb_main_deck_cards = generate_numb_main_deck(options[:main_deck][:count])

    if rand(2) == 1
      deck.skill_card_art_id = @@skill_cards.sample.card_art_ids[0]
    end

    cards = []
    cards.concat(@@main_deck_cards.sample(numb_main_deck_cards))
    cards.concat(generate_extra_deck(options[:extra_deck]))
    # cards.concat(@@extra_deck_cards.sample(numb_extra_deck_cards).map { |card| [1, card.card_art_ids.sample] })

    r = CardArt.select(:id, :card_id).where(card_id: cards.map(&:id)).group_by(&:card_id)
    card_art_ids = r.map do |card_id, card_art_ids|
      [1, card_art_ids.sample.id]
    end
    deck.name = "Deck ##{(Deck.count + 1).to_fs(:delimited)}"
    Deck.transaction do
      deck.save
      DeckCardArt.insert_all(card_art_ids.map do |copies, card_art_id|
        {deck_id: deck.id, card_art_id: card_art_id, copies: copies}
      end)
    end

    deck
  end

  private

  def self.generate_numb_main_deck(option)
    case option
    when nil
      numb = rand(6)
      case numb
      when 0..2
        40
      when 3..4
        60
      when 5
        rand(41..59)
      end
    when Numeric
      option.to_i
    when Range
      rand(option)
    when Array
      option.sample
    end
  end

  def self.generate_numb_extra_deck(option)
    case option
    when nil
      numb = rand(10)
      case numb
      when 0..5
        15
      when 6..8
        rand(1..14)
      when 9
        0
      end
    when Numeric
      option.to_i
    when Range
      rand(option)
    when Array
      option.sample
    end
  end

  def self.generate_extra_deck(options)
    # puts "options: #{options}"
    total = generate_numb_extra_deck(options[:count])

    randomized_partition = Card.with(randomized: Card.select(:id, :macro_frame_type).where(extra_deck: true).order("random()"))
                               .with(randomized_partition: Card.select(Arel.star, "row_number() over (partition by macro_frame_type) as r").from("randomized"))

    total_required = options.filter do |key, hash|
      hash.is_a?(Hash)
    end.sum do |key, hash|
      hash[:count].begin
    end

    required_query = randomized_partition.from("randomized_partition AS cards")
    required_query = options.filter do |key, hash|
      hash.is_a?(Hash) && hash[:count]
    end.map do |option, hash|
      required_amount = hash[:count].begin
      required_query.where(macro_frame_type: option).where("r <= ?", required_amount)
    end.reduce do |q1, q2|
      q1.or(q2)
    end

    rest_query = randomized_partition.from("randomized_partition AS cards").order("random()")
    rest_query = options.filter do |key, hash|
      hash.is_a?(Hash) && hash[:count].size > 1
    end.map do |option, hash|
      min = hash[:count].begin
      max = [total - total_required + hash[:count].begin, hash[:count].end].min
      query = rest_query.where(macro_frame_type: option)
      query = query.where("r > ?", min) if min > 0
      query.where("r <= ?", max)
    end.reduce do |q1, q2|
      q1.or(q2)
    end

    Card.union_all(required_query, rest_query).limit(total).load

    # WITH randomized as (
    #   SELECT id, macro_frame_type, name
    #     FROM cards
    #     WHERE extra_deck IS TRUE
    #     ORDER BY random()
    # ),
    # randomized_partition AS (
    #   SELECT row_number() over (partition by macro_frame_type) as r, t.*
    #     FROM randomized t
    # )
    # SELECT * FROM (
    #   SELECT * FROM (
    #     SELECT id, name, macro_frame_type, r
    #       FROM randomized_partition
    #       WHERE (macro_frame_type = 'fusion' AND r <= 2)
    #       OR (macro_frame_type = 'synchro' AND r <= 3)
    #       OR (macro_frame_type = 'xyz' AND r <= 2)
    #       OR (macro_frame_type = 'link' AND r <= 1)
    #     UNION ALL
    #       (
    #         SELECT id, name, macro_frame_type, r
    #           FROM randomized_partition
    #           WHERE (macro_frame_type = 'fusion' AND r > 2 AND r <= 2)
    #           OR (macro_frame_type = 'synchro' AND r > 3 AND r <= 6)
    #           OR (macro_frame_type = 'xyz' AND r > 0 AND r <= 3)
    #           OR (macro_frame_type = 'link' AND r > 0 AND r <= 15)
    #         ORDER BY random()
    #       )
    #     )
    # --     ORDER BY order_col
    #     LIMIT 12
    #   )
    #   ORDER BY macro_frame_type

    # r = complete_query
    # r.load
  end
end

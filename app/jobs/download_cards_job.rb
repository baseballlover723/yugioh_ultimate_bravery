class DownloadCardsJob < ApplicationJob
  LOCAL_CACHE_FILE = "./all_cards.local.json"
  LOCAL_JSON_DEBUG_FILE = "./all_cards_debug.local.json"
  LOCAL_ALL_KEYS_DEBUG_FILE = "./all_keys.local.json"

  CARD_DATA_URL = "https://db.ygoprodeck.com/api/v7/cardinfo.php"
  CACHE_FILE_LIFETIME = 1.days

  queue_as :default

  def perform(*args)
    cards_json = self.class.fetch_cards_info

    # generate_all_keys_file(cards_json["data"])
    # list_frame_types(cards_json["data"])

    logger.debug "Parsing data"
    parse_start = Time.now
    card_params = cards_json["data"].reject do |card|
      card["frameType"] == "token"
    end.map do |card|
      Card.translate_ygo_pro_deck_params(card)
    end
    card_upsert_start = Time.now
    logger.info "Parsing data took #{(card_upsert_start - parse_start).to_human_duration} seconds"

    old_logger_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1
    logger.debug "Upserting card data"
    ids = Card.upsert_all(card_params, record_timestamps: true)
    skill_card_upsert_start = Time.now
    logger.info "Upserting card data #{ids.rows.size.to_fs(:delimited)} rows inserted. Took #{(skill_card_upsert_start - card_upsert_start).to_human_duration} seconds"

    ActiveRecord::Base.logger.level = old_logger_level
  end

  def self.fetch_cards_info
    if Rails.env.local? && File.exist?(LOCAL_CACHE_FILE) && Time.now - File.mtime(LOCAL_CACHE_FILE) < CACHE_FILE_LIFETIME
      logger.info "Using locally cached file"
      return JSON.parse(File.read(LOCAL_CACHE_FILE))
    end

    logger.info "Updating card data"
    resp = HTTParty.get(CARD_DATA_URL)
    json = resp.parsed_response

    if Rails.env.local?
      File.write(LOCAL_CACHE_FILE, resp.body)
      generate_json_debug_file(json["data"])
    end
    json
  end

  private

  # a file that has ~120 cards in it, keyed off of unique fields
  # should have every possible card combo
  def self.generate_json_debug_file(cards)
    set_hash = Hash.new { |hsh, k| hsh[k] = Set.new }
    debug_cards = []
    debug_json = {"data" => debug_cards}
    # drop 100 to skip names starting with quotes
    cards.drop(100).each do |card|
      bools = [
        set_hash[:type].add?(card["type"]),
        set_hash[:frame_type].add?(card["frameType"]),
        set_hash[:race].add?(card["race"]),
        set_hash[:numb_card_images].add?(card["card_images"].size)
      ]
      debug_cards << card if bools.any?
    end
    File.write(LOCAL_JSON_DEBUG_FILE, JSON.pretty_generate(debug_json))
  end

  def list_frame_types(cards)
    frame_types = Hash.new { |hsh, k| hsh[k] = Hash.new(0) }
    cards.each do |card|
      frame_types[card["frameType"]]["total"] += 1
      frame_types[card["frameType"]][card["type"]] += 1
    end
    puts "frame_types:"
    frame_types.each do |frame_type, hsh|
      hsh.delete("total") if hsh.size == 2
      puts "frame_type: #{frame_type}: #{hsh}"
    end
  end

  def generate_all_keys_file(cards)
    keys = {}
    cards.each do |card|
      card.each do |key, val|
        next if keys.include?(key)
        keys[key] = val
      end
    end
    File.write(LOCAL_ALL_KEYS_DEBUG_FILE, JSON.pretty_generate(keys))
  end
end

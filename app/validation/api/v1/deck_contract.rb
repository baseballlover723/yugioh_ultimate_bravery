class Api::V1::DeckContract < Dry::Validation::Contract
  CONSTRAINTS = {
    extra_deck:
      {count: {min: 0, max: 15}, level: {min: 0, max: 13}, atk: {min: 0, max: 5000}, def: {min: 0, max: 5000},
       card_attributes: Set["FIRE", "WIND", "WATER", "DARK", "EARTH", "LIGHT"],
       races: Set["Aqua", "Dragon", "Reptile", "Sea Serpent", "Cyberse", "Rock", "Illusion", "Spellcaster", "Wyrm", "Plant", "Zombie", "Machine", "Thunder", "Winged Beast", "Pyro", "Beast", "Fish", "Fairy", "Psychic", "Insect", "Dinosaur", "Beast-Warrior", "Warrior", "Fiend"]
      }
  }
  gen_keys = -> (key) { [key, (key.to_s + "_min").to_sym, (key.to_s + "_max").to_sym] }
  range_keys = Hash.new { |hsh, k| hsh[k] = gen_keys.call(k) }
  with_range = -> (obj, key, range_keys, min_max) do
    obj.optional(key).maybe(:integer, gteq?: min_max[:min], lteq?: min_max[:max])
    obj.optional(range_keys[key][1]).maybe(:integer, gteq?: min_max[:min], lteq?: min_max[:max])
    obj.optional(range_keys[key][2]).maybe(:integer, gteq?: min_max[:min], lteq?: min_max[:max])
  end
  enum = -> (obj, key, type_klass, values) do
    obj.optional(key).maybe(:array, size?: 1..values.size) do
      nil? | each { type?(type_klass) & included_in?(values) }
    end

  end

  json do
    optional(:extra_deck).maybe(:hash) do
      with_range.call(self, :count, range_keys, CONSTRAINTS[:extra_deck][:count])

      Card::EXTRA_DECK_MACRO_FRAME_TYPES.each do |extra_type|
        optional(extra_type).maybe(:hash) do
          with_range.call(self, :count, range_keys, CONSTRAINTS[:extra_deck][:count])

          with_range.call(self, :level, range_keys, CONSTRAINTS[:extra_deck][:level])
          with_range.call(self, :atk, range_keys, CONSTRAINTS[:extra_deck][:atk])
          with_range.call(self, :def, range_keys, CONSTRAINTS[:extra_deck][:def])

          enum.call(self, :card_attributes, String, CONSTRAINTS[:extra_deck][:card_attributes])
          enum.call(self, :races, String, CONSTRAINTS[:extra_deck][:races])

        end
      end
    end
  end

  rule(extra_deck: range_keys[:count]) do
    validate_range(self, range_keys[:count], values.dig(:extra_deck), "extra_deck")
  end

  Card::EXTRA_DECK_MACRO_FRAME_TYPES.each do |extra_type|
    str_path = "extra_deck." + extra_type.to_s
    rule({extra_deck: {extra_type => range_keys[:count]}}) do
      validate_range(self, range_keys[:count], values.dig(:extra_deck, extra_type), str_path)
    end

    rule({extra_deck: {extra_type => range_keys[:level]}}) do
      validate_range(self, range_keys[:level], values.dig(:extra_deck, extra_type), str_path)
    end

    rule({extra_deck: {extra_type => range_keys[:atk]}}) do
      validate_range(self, range_keys[:atk], values.dig(:extra_deck, extra_type), str_path)
    end

    rule({extra_deck: {extra_type => range_keys[:def]}}) do
      validate_range(self, range_keys[:def], values.dig(:extra_deck, extra_type), str_path)
    end

    rule({extra_deck: {extra_type => :card_attributes}}) do
      convert_to_set(self, :card_attributes, values.dig(:extra_deck, extra_type), str_path)
    end

    rule({extra_deck: {extra_type => :races}}) do
      convert_to_set(self, :races, values.dig(:extra_deck, extra_type), str_path)
    end
  end

  def convert_to_set(obj, key, hash, path)
    return if hash.nil?
    if obj.schema_error?(path + ".#{key}")
      # bail out here if has schema error
    elsif hash[key].nil?
      hash[key] = :default
    else
      hash[key] = hash[key].to_set
    end
  end

  def validate_range(obj, keys, hash, path)
    return if hash.nil?
    normal_key, min_key, max_key = keys
    if hash[normal_key].nil? && hash[min_key].nil? && hash[max_key].nil?
      hash[normal_key] = :default
    elsif hash[normal_key] && (hash[min_key] || hash[max_key])
      obj.key.failure("Both #{normal_key}s are defined. Only \"#{normal_key}\" or (\"#{min_key}\" and \"#{max_key}\") should be defined")
    elsif obj.schema_error?(path + ".#{normal_key}")
      # bail out here if has schema error
    elsif hash[normal_key]
      hash[normal_key] = hash[normal_key]..hash[normal_key]
    elsif hash[min_key].nil? || hash[max_key].nil?
      if hash[min_key].nil?
        obj.key.failure("\"#{min_key}\" is required with \"#{max_key}\"")
      else
        obj.key.failure("\"#{max_key}\" is required with \"#{min_key}\"")
      end
    elsif obj.schema_error?(path + ".#{min_key}") || obj.schema_error?(path + ".#{max_key}")
      # bail out here if has schema error
    elsif hash[min_key] > hash[max_key]
      obj.key.failure("\"#{min_key}\" (#{hash[min_key]}) is larger then \"#{max_key}\" (#{hash[max_key]})")
    else
      hash[normal_key] = hash[min_key]..hash[max_key]
      hash.delete(min_key)
      hash.delete(max_key)
    end
  end
end

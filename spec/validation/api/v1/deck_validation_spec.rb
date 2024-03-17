require "rails_helper"

RSpec.describe Api::V1::DeckContract do
  generate_range_test_cases = -> (rspec, keys, top_options_arr) do
    keys.each do |key|
      rspec.describe "#{key} range validation" do
        min_max = Api::V1::DeckContract::CONSTRAINTS[:extra_deck][key]
        keys = [key, "#{key}_min".to_sym, "#{key}_max".to_sym]
        normal_key, min_key, max_key = keys
        valid_values = [min_max[:min], rand((min_max[:min] + 1)...min_max[:max]), min_max[:max]]
        invalid_values = [min_max[:min] - 1, min_max[:max] + 1, "5"]

        values = [[true, {}], [true, {normal_key => nil, min_key => nil, max_key => nil}]]
        values << [true, {normal_key => valid_values.sample, min_key => nil, max_key => nil}]
        valid_values.each do |val|
          values << [true, {normal_key => val}]
        end
        values << [true, {normal_key => nil, min_key => valid_values.first, max_key => valid_values.last}]
        valid_values.each do |min_val|
          valid_values.each do |max_val|
            values << [min_val <= max_val, {min_key => min_val, max_key => max_val}, min_val <= max_val]
          end
        end

        values << [false, {normal_key => invalid_values.sample, min_key => nil, max_key => nil}]
        invalid_values.each do |val|
          values << [false, {normal_key => val}]
        end
        valid_values.each do |val|
          values << [false, {normal_key => val, min_key => val, max_key => val}]
        end
        valid_values.each do |val|
          values << [false, {min_key => val}]
          values << [false, {max_key => val}]
        end
        valid_values.each do |valid_val|
          invalid_values.each do |invalid_val|
            values << [false, {min_key => valid_val, max_key => invalid_val}]
            values << [false, {min_key => invalid_val, max_key => valid_val}]
          end
        end

        values.sort_by!.with_index { |arr, i| [arr.first ? -1 : 1, i] }
        values.each do |passes, hash|
          it "#{hash.to_json} => #{passes}" do
            top_options = generate_top_options(top_options_arr, hash)
            result = subject.call(top_options)
            # puts "result: #{result.inspect}"
            if passes
              expect(result.errors).to be_empty
              expect(result.values.dig(*top_options_arr, key)).to be_a(Range).or be(:default)
            else
              expect(result.errors).not_to be_empty
            end
          end
        end
      end
    end
  end

  generate_array_enum_test_cases = -> (rspec, keys, valid_values, invalid_values, top_options_arr) do
    keys.each do |key|
      rspec.describe "#{key} set enum validation" do
        values = [[true, nil]]
        valid_values.each { |val| values << [true, [val]] }
        valid_values.combination(2) { |arr| values << [true, arr] }
        values << [true, valid_values]
        values << [false, valid_values.dup + [valid_values.sample]]

        values << [false, []]
        invalid_values.each do |val|
          values << [false, [val]]
          rand_valid = valid_values.sample
          values << [false, [val, rand_valid]]
          values << [false, [rand_valid, val]]
        end

        values.sort_by!.with_index { |arr, i| [arr.first ? -1 : 1, i] }
        values.each do |passes, arr|
          hash = {key => arr}
          it "#{hash.to_json} => #{passes}" do
            top_options = generate_top_options(top_options_arr, hash)
            result = subject.call(top_options)
            # puts "result: #{result.inspect}"
            if passes
              expect(result.errors).to be_empty
              expect(result.values.dig(*top_options_arr, key)).to be_a(Set).or be(:default)
            else
              expect(result.errors).not_to be_empty
            end
          end
        end

      end
    end
  end

  describe "extra_deck" do
    generate_range_test_cases.call(self, [:count], [:extra_deck])

    Card::EXTRA_DECK_MACRO_FRAME_TYPES.each do |extra_type|
      describe "#{extra_type}" do
        generate_range_test_cases.call(self, [:count, :level, :atk, :def], [:extra_deck, extra_type])

        generate_array_enum_test_cases.call(
          self, [:card_attributes], Api::V1::DeckContract::CONSTRAINTS[:extra_deck][:card_attributes].to_a, [nil, 123, "not_in_enum"], [:extra_deck, extra_type])

        generate_array_enum_test_cases.call(
          self, [:races], Api::V1::DeckContract::CONSTRAINTS[:extra_deck][:races].to_a, [nil, 123, "not_in_enum"], [:extra_deck, extra_type])
      end
    end
  end

  def generate_top_options(top_options_arr, hash)
    top_options_arr.reverse_each.reduce(hash) do |c_hash, key|
      {key => c_hash}
    end
  end
end


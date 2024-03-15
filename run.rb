# ttotals = Hash.new(0)
# tlist1s = Hash.new(0)
# tlist2s = Hash.new(0)
# tlist3s = Hash.new(0)
#
# 100_000.times do
#   l1 = 0
#   l2 = 0
#   l3 = 0
#   total_elements = rand(9..16)
#   while l1 + l2 + l3 != total_elements
#     l1 = rand(5..10)
#     l2 = rand(3..7)
#     l3 = rand(1..3)
#   end
#   ttotals[total_elements] += 1
#   tlist1s[l1] += 1
#   tlist2s[l2] += 1
#   tlist3s[l3] += 1
# end
# puts "true"
# puts "total_elements: #{ttotals.to_a.sort}"
# puts "list1: #{tlist1s.to_a.sort}"
# puts "list2: #{tlist2s.to_a.sort}"
# puts "list3: #{tlist3s.to_a.sort}"
#
#
# totals = Hash.new(0)
# list1s = Hash.new(0)
# list2s = Hash.new(0)
# list3s = Hash.new(0)
#
# 100_000.times do
#   # total_elements = rand(9..16)
#   # list1_count = rand([5, total_elements - 8].max..[10, total_elements - 4].min)
#   # list2_count = rand([3, total_elements - list1_count - 1].max..[7, total_elements - list1_count - 1].min)
#   # list3_count = total_elements - list1_count - list2_count
#
#   # total_elements = rand(9..16)
#   # list1_count = rand([5, total_elements - 9].max..[10, total_elements - 4].min)
#   # list2_count = rand([3, total_elements - list1_count - 3].max..[7, total_elements - list1_count - 1].min)
#   # list3_count = rand(1..[3, total_elements - list1_count - list2_count].min)
#
#   total_elements = rand(9..16)
#   l1 = 5
#   l2 = 3
#   l3 = 1
#   left = total_elements - l1 - l2 - l3
#   # try get all of the rows
#   # then in ruby, iterate over array
#   # getting first total_elements rows
#
#   # try get min rows randomly
#   # get all rows, group by frame_type
#   # merge like frame_types
#   # get total_element - min rows randomly
#
#
#   totals[total_elements] += 1
#   list1s[l1] += 1
#   list2s[l2] += 1
#   list3s[l3] += 1
# end
# puts "total_elements: #{totals.to_a.sort}"
# puts "list1: #{list1s.to_a.sort}"
# puts "list2: #{list2s.to_a.sort}"
# puts "list3: #{list3s.to_a.sort}"

options = {
  count: 13,
  fusion: {
    count: 2..2,
    level: nil,
    atk: nil,
    def: nil,
    card_attribute: nil,
    card_type: nil
  },
  synchro: {
    count: 3..6,
    level: nil,
    atk: nil,
    def: nil,
    card_attribute: nil,
    card_type: nil
  },
  xyz: {
    count: 0..3,
    level: nil,
    atk: nil,
    def: nil,
    card_attribute: nil,
    card_type: nil
  },
  link: {
    # count: 0..2,
    count: 0..15,
    level: nil,
    atk: nil,
    def: nil,
    card_attribute: nil,
    card_type: nil
  }
}

def test(name, options)
  hash = Hash.new() { |hsh, k| hsh[k] = Hash.new(0) }
  puts "\nrunning #{name}"
  start = Time.now
  finish = -> (item, i, cards) do
    hash["total"][cards.size] += 1
    counts = cards.group_by(&:macro_frame_type).transform_values do |arr|
      arr.size
    end
    ["fusion", "synchro", "xyz", "link"].each do |key|
      hash[key][counts[key] || 0] += 1
    end
  end
  # Rails.logger.level = :info
  # Parallel.each(1..250_000, in_processes: 18, progress: "Running queries", finish: finish) do |i|
  # Parallel.each(1..100_000, in_processes: 18, progress: "Running queries", finish: finish) do |i|
  # Parallel.each(1..1_000, in_processes: 18, progress: "Running queries", finish: finish) do |i|
  Parallel.each(1..1, in_threads: 0, finish: finish) do |i|
    cards = []
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.uncached do
        # cards = DeckService.generate_extra_deck(options)
        cards = DeckService.send(name, options)
      end
    end
    cards
  end
  #   .each do |cards|
  #   hash["total"][cards.size] += 1
  #   counts = cards.group_by(&:macro_frame_type).transform_values do |arr|
  #     arr.size
  #   end
  #   ["fusion", "synchro", "xyz", "link"].each do |key|
  #     hash[key][counts[key] || 0] += 1
  #   end
  # end

  hash.transform_values! do |arr|
    arr.sort
  end
  longest_arr = (hash.values.map(&:size).max)
  sizes = (0...longest_arr).map do |i|
    hash.map do |key, arr|
      element = arr[i] || [0, 0]
      element[-1].to_fs(:delimited).size
    end.max
  end
  ["  total", " fusion", "synchro", "    xyz", "   link"].each do |key|
    puts "#{key}: #{hash[key.strip].map.with_index { |(n_cards, count), i| "#{n_cards.to_s.rjust(2, ' ')}: #{count.to_fs(:delimited).rjust(sizes[i], ' ')}" }.join(", ")}"
  end
  puts "took #{Time.now - start} seconds"
end

test(:generate_extra_deck, options)
# test(:generate_extra_deck_without_order_col_in_union, options)

# test(:generate_extra_deck_optimized_just_id, options)
# test(:generate_extra_deck_optimized_just_id_final1, options)
# test(:generate_extra_deck_optimized_just_id_final2, options)
# test(:generate_extra_deck_optimized_just_id_and_query_arts_separate, options)

# test(:generate_extra_deck_without_rest_order_by_random, options)
# test(:generate_extra_deck_without_order_col_in_union_and_rest_order_by_random, options)

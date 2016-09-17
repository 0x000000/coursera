require 'minitest/spec'
require 'minitest/autorun'
require 'set'

alias context describe

def count_2_sum(sorted_array, min = -10_000, max = 10_000)
  return 0 if sorted_array.size < 2

  uniq_sums  = Set.new
  head, tail = 0, sorted_array.size - 1
  reverse    = nil

  while tail > head
    sum = sorted_array[head] + sorted_array[tail]

    if sum < min
      reverse = false
      head    += 1
      next
    end

    if sum > max
      reverse = true
      tail    -= 1
      next
    end

    if reverse
      tmp_head = head

      while sum <= max && tail > tmp_head
        uniq_sums.add(sum)
        tmp_head += 1

        sum = sorted_array[tmp_head] + sorted_array[tail]
      end

      tail -= 1
    else
      tmp_tail = tail

      while sum >= min && tmp_tail > head
        uniq_sums.add(sum)
        tmp_tail -= 1

        sum = sorted_array[head] + sorted_array[tmp_tail]
      end

      head += 1
    end
  end

  uniq_sums.size
end

describe '#count_2_sum' do
  it do
    count_2_sum([]).must_equal 0
    count_2_sum([1]).must_equal 0

    count_2_sum([1, 2], 1, 3).must_equal 1
    count_2_sum([1, 1, 2], 1, 3).must_equal [1+1, 1+2].size
    count_2_sum([1, 2, 3, 4, 5, 7], 2, 5).must_equal [1+2, 1+3, (1+4) + (2+3)].size
    count_2_sum([1, 2, 3, 5, 7, 12], 4, 11).must_equal [1 + 3 - 4, 1 + 5 - 6, 1 + 7 - 8, 2 + 3 - 5, 2 + 5 - 7, 2 + 7 - 9, 3 + 7 - 10].size
  end
end

def calculate_sums
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  array = File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    line.to_i
  end.sort

  puts "\n"
  puts '-' * 50
  puts "Sums: #{count_2_sum(array.sort)}"
  puts '-' * 50
  puts "\n"
end

calculate_sums

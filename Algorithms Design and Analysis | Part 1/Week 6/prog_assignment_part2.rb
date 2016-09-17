require 'minitest/spec'
require 'minitest/autorun'
require 'pqueue' # gem install pqueue

alias context describe

def median_maintenance(input)
  sum = 0

  low_heap = PQueue.new
  high_heap = PQueue.new

  input.each do |element|
    if low_heap.size == 0 || low_heap.top > element
      low_heap.push(element)
    else
      high_heap.push(element * -1)
    end

    # balance
    if high_heap.size > low_heap.size
      low_heap.push(high_heap.pop * -1)
    elsif low_heap.size > high_heap.size + 1
      high_heap.push(low_heap.pop * -1)
    end

    sum += low_heap.top
  end

  sum
end

describe '#median_maintenance' do
  it do
    median_maintenance([5]).must_equal 5
    median_maintenance([5, 15]).must_equal 10
    median_maintenance([5, 15, 1]).must_equal 15
    median_maintenance([5, 15, 1, 3]).must_equal 18
  end
end

def calculate_median
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  array = File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    line.to_i
  end

  puts "\n"
  puts '-' * 50
  puts "Sums: #{median_maintenance(array) % 10_000}"
  puts '-' * 50
  puts "\n"
end

calculate_median

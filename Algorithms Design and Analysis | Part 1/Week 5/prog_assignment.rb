require 'pqueue' # gem install pqueue
require 'minitest/spec'
require 'minitest/autorun'

alias context describe

def dijkstra(adjacent_weight_list, source = 0)
  min_distance = []
  visited      = []
  heap         = PQueue.new { |a, b| (min_distance[b] || Float::INFINITY) > (min_distance[a] || Float::INFINITY) }

  min_distance[source] = 0
  visited[source] = true
  heap.push(source)

  while heap.size > 0
    v = heap.pop
    visited[v] = true

    next unless adjacent_weight_list[v]

    adjacent_weight_list[v].each do |w, w_weight|
      next if visited[w]

      w_distance = min_distance[v] + w_weight
      next unless (min_distance[w] || Float::INFINITY) > w_distance

      min_distance[w] = w_distance
      heap.push(w)
    end
  end

  min_distance
end

describe "#dijkstra" do
  it do
    adjacent_weight_list = {
      0 => {1 => 11, 2 => 2},
      1 => {2 => 1},
    }

    dijkstra(adjacent_weight_list).must_equal [0, 11, 2]


    adjacent_weight_list = {
      0 => {1 => 1, 7 => 2},
      1 => {0 => 1, 2 => 1},
      2 => {1 => 1, 3 => 1},
      3 => {2 => 1, 4 => 1},
      4 => {3 => 1, 5 => 1},
      5 => {4 => 1, 6 => 1},
      6 => {5 => 1, 7 => 1},
      7 => {6 => 1, 0 => 2},
    }

    dijkstra(adjacent_weight_list).must_equal [0, 1, 2, 3, 4, 4, 3, 2]


    adjacent_weight_list = {
      0 => {5 => 14, 2 => 9, 1 => 7},
      1 => {0 => 7, 2 => 10, 3 => 15},
      2 => {0 => 9, 5 => 2, 3 => 11, 1 => 10},
      3 => {4 => 6, 2 => 11, 1 => 15},
      4 => {5 => 9, 3 => 6},
      5 => {0 => 14, 2 => 2, 4 => 9},
    }

    dijkstra(adjacent_weight_list).must_equal [0, 7, 9, 20, 20, 11]
  end
end

def calculate_distances
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  list = Hash[File.readlines(ENV['INPUT_FILE_PATH']).map.with_index do |line, index|
    [index, Hash[line.split(' ')[1..-1].map do |pair|
      vertex, weight = pair.split(',')
      [vertex.to_i - 1, weight.to_i]
    end]]
  end]

  distances = dijkstra(list)

  puts "\n"
  puts '-' * 50
  puts "Distances: #{[7, 37, 59, 82, 99, 115, 133, 165, 188, 197].map { |vertex| distances[vertex - 1] }}"
  puts '-' * 50
  puts "\n"
end

calculate_distances

require 'minitest/spec'
require 'minitest/autorun'

alias context describe

PICK_FIRST = lambda do |graph|
  fold_from = graph.keys.first
  edges     = graph[fold_from]

  [fold_from, edges.first]
end

PICK_RANDOM = lambda do |hash|
  fold_from = hash.keys.sample
  edges     = hash[fold_from]

  [fold_from, edges.sample].shuffle
end

def fold_graph(fold_from, fold_to, graph)
  folded_edges = graph.delete(fold_from)

  folded_edges.each do |edge|
    graph[edge].map! do |link_node|
      if link_node == fold_from
        fold_to
      else
        link_node
      end
    end
  end

  graph[fold_to] += folded_edges
  graph[fold_to].delete_if do |edge|
    edge == fold_from || edge == fold_to
  end

  graph
end

def min_cuts(graph, pick_edge = PICK_RANDOM)
  if graph.keys.size == 2
    graph[graph.keys.first].size
  else
    fold_from, fold_to = pick_edge.call(graph)
    fold_graph(fold_from, fold_to, graph)
    min_cuts(graph, pick_edge)
  end
end

describe '#PICK_FIRST' do
  it { PICK_FIRST.call({1 => [2], 2 => [1]}).must_equal [1, 2] }
end

describe '#fold_graph' do
  it do
    fold_graph(
      3, 1, {1 => [2, 3], 2 => [1, 3], 3 => [2, 1]}
    ).must_equal(
      {1 => [2, 2], 2 => [1, 1]}
    )
  end

  it do
    fold_graph(
      3, 1, {1 => [2, 3, 4], 2 => [1, 3], 3 => [2, 1, 4], 4 => [1, 3]}
    ).must_equal(
      {1 => [2, 4, 2, 4], 2 => [1, 1], 4 => [1, 1]}
    )
  end

  it do
    fold_graph(
      4, 1, {1 => [2, 4, 2, 4], 2 => [1, 1], 4 => [1, 1]}
    ).must_equal(
      {1 => [2, 2], 2 => [1, 1]}
    )
  end

  it do
    fold_graph(
      3, 1, {1 => [2, 3, 4], 2 => [1, 3, 4], 3 => [2, 1, 4], 4 => [1, 2, 3]}
    ).must_equal(
      {1 => [2, 4, 2, 4], 2 => [1, 1, 4], 4 => [1, 2, 1]}
    )
  end

  it do
    fold_graph(
      3, 1, {1 => [2, 3, 4], 2 => [1, 3, 4], 3 => [2, 1, 4], 4 => [1, 2, 3]}
    ).must_equal(
      {1 => [2, 4, 2, 4], 2 => [1, 1, 4], 4 => [1, 2, 1]}
    )
  end

  it do
    fold_graph(
      2, 1, {1 => [3, 2, 5], 2 => [3, 1, 4, 6], 3 => [1, 2, 4], 4 => [3, 2], 5 => [1, 6], 6 => [2, 5]}
    ).must_equal(
      {1 => [3, 5, 3, 4, 6], 3 => [1, 1, 4], 4 => [3, 1], 5 => [1, 6], 6 => [1, 5]}
    )
  end

  it do
    initial = {
      1 => [2, 3, 4, 7],
      2 => [1, 3, 4,],
      3 => [1, 2, 4,],
      4 => [1, 2, 3, 5],
      5 => [4, 6, 7, 8],
      6 => [5, 7, 8,],
      7 => [1, 5, 6, 8],
      8 => [5, 6, 7,],
    }

    expected = {
      1 => [2, 3, 4, 6],
      2 => [1, 3, 4,],
      3 => [1, 2, 4,],
      4 => [1, 2, 3, 5],
      5 => [4, 6, 6, 8],
      6 => [5, 8, 1, 5, 8],
      8 => [5, 6, 6,],
    }

    fold_graph(7, 6, initial).must_equal expected
  end

  it do
    initial = {
      1 => [2, 3, 4, 4],
      2 => [1, 3, 4, 4],
      3 => [1, 2, 4, 4, 5],
      4 => [1, 1, 2, 2, 3, 3, 5, 5],
      5 => [3, 4, 4],
    }

    expected = {
      1 => [2, 3, 3, 3],
      2 => [1, 3, 3, 3],
      3 => [1, 2, 5, 1, 1, 2, 2, 5, 5],
      5 => [3, 3, 3],
    }

    fold_graph(4, 3, initial).must_equal expected
  end

  it do
    input = {
      1 => [2, 3, 4, 7],
      2 => [1, 3, 4,],
      3 => [1, 2, 4,],
      4 => [1, 2, 3, 5],
      5 => [4, 6, 7, 8],
      6 => [5, 7, 8,],
      7 => [1, 5, 6, 8],
      8 => [5, 6, 7,],
    }

    graph = fold_graph(2, 1, input.dup)
    graph = fold_graph(3, 1, graph)
    graph = fold_graph(4, 1, graph)
    graph = fold_graph(8, 6, graph)
    graph = fold_graph(5, 6, graph)
    graph = fold_graph(6, 7, graph)

    graph.must_equal({1 => [7, 7], 7 => [1, 1]})
  end
end

describe '#min_cuts' do
  context 'for undirected graphs with' do
    context '2 nodes' do
      it { min_cuts({1 => [2], 2 => [1]}).must_equal 1 }
      it { min_cuts({1 => [2, 2], 2 => [1, 1]}).must_equal 2 }
      it { min_cuts({1 => [2, 2, 2], 2 => [1, 1, 1]}).must_equal 3 }
    end

    context '> 2 nodes' do
      it { min_cuts({1 => [2, 3], 2 => [1, 3], 3 => [1, 2]}, PICK_FIRST).must_equal 2 }
      it { min_cuts({1 => [2, 3, 4], 2 => [1, 3], 3 => [2, 1, 4], 4 => [1, 3]}, PICK_FIRST).must_equal 2 }
      it { min_cuts({1 => [2, 3, 4], 2 => [1, 3, 4], 3 => [2, 1, 4], 4 => [1, 3, 2]}, PICK_FIRST).must_equal 3 }
    end
  end
end

def calculate_min_cuts
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  graph = Hash[File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    nodes = line.split("\t")[0...-1].map do |node|
      node.to_i
    end

    [
      nodes.first,
      nodes[1..-1]
    ]
  end]

  min_rnd_cuts = [100, graph.keys.size].max.times.map do
    new_graph = Hash[graph.keys.map do |key|
      [key, graph[key].dup]
    end]

    min_cuts(new_graph, PICK_RANDOM)
  end.min

  puts "\n"
  puts '-' * 50
  puts "Min cuts: #{min_rnd_cuts}"
  puts '-' * 50
  puts "\n"
end

calculate_min_cuts

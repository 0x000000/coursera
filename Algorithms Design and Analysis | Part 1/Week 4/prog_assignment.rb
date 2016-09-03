#
# WARNING!
#
# To run this code you must use jruby with flags:
#  -J-Xmn512m -J-Xms4096m -J-Xmx4096m -J-Xss1024M -J-server
#

require 'minitest/spec'
require 'minitest/autorun'

alias context describe

class Graph
  attr_reader :adjacency_list, :reversed_adjacency_list

  def initialize(edges)
    @adjacency_list          = []
    @reversed_adjacency_list = []

    edges.each do |head, tail|
      @adjacency_list[head - 1] ||= []
      @adjacency_list[tail - 1] ||= []
      @adjacency_list[head - 1] << tail - 1

      @reversed_adjacency_list[head - 1] ||= []
      @reversed_adjacency_list[tail - 1] ||= []
      @reversed_adjacency_list[tail - 1] << head - 1
    end
  end
end

class DFS
  attr_reader :explored

  def initialize(adjacency_list)
    @explored = []

    @finishing_time_vertices = []
    @finishing_time = 0

    @strongly_connected_components = []
    @scc_size = 0

    @adjacency_list = adjacency_list
  end

  def detect_finishing_times!
    (@adjacency_list.size - 1).downto(0) do |vertex|
      unless @explored[vertex]
        depth_first_search(vertex)
      end
    end

    @finishing_time_vertices
  end

  def detect_sccs!(substitution_list)
    (@adjacency_list.size - 1).downto(0) do |vertex|
      unless @explored[substitution_list[vertex]]
        @scc_size = 0
        depth_first_search(substitution_list[vertex])
        @strongly_connected_components << @scc_size
      end
    end

    @strongly_connected_components
  end

  private

  def depth_first_search(vertex)
    @explored[vertex] = true
    @adjacency_list[vertex].each do |connected_vertex|
      unless @explored[connected_vertex]
        depth_first_search(connected_vertex)
      end
    end

    @finishing_time_vertices[@finishing_time] = vertex
    @finishing_time += 1
    @scc_size += 1
  end
end

def unleash_the_power_of_kosaraju!(graph)
  first_scan = DFS.new(graph.reversed_adjacency_list)
  second_scan = DFS.new(graph.adjacency_list)

  (second_scan.detect_sccs!(first_scan.detect_finishing_times!).sort.reverse + [0, 0,0,0,0])[0...5]
end

describe Graph do
  describe '#initialize' do
    it do
      graph = Graph.new [[1, 2], [1, 3], [3, 2]]
      graph.adjacency_list.must_equal [[1, 2], [], [1]]
      graph.reversed_adjacency_list.must_equal [[], [0, 2], [0]]

      graph = Graph.new [[1, 3], [1, 2], [3, 2]]
      graph.adjacency_list.must_equal [[2, 1], [], [1]]
      graph.reversed_adjacency_list.must_equal [[], [0, 2], [0]]
    end
  end
end

describe DFS do
  describe '#scan!' do
    it do
      graph = Graph.new [[1, 3], [2, 1], [3, 2]]
      dfs   = DFS.new(graph.adjacency_list)

      dfs.detect_finishing_times!.must_equal [0, 1, 2]
      dfs.explored.must_equal ([true] * 3)


      graph = Graph.new [[1, 2], [1, 3], [3, 2]]
      dfs   = DFS.new(graph.adjacency_list)

      dfs.detect_finishing_times!.must_equal [1, 2, 0]
      dfs.explored.must_equal ([true] * 3)


      graph = Graph.new [[1, 2], [2, 3], [4, 1], [4, 3]]
      dfs   = DFS.new(graph.adjacency_list)

      dfs.detect_finishing_times!.must_equal [2, 1, 0, 3]
      dfs.explored.must_equal ([true] * 4)


      graph = Graph.new [[1, 2], [2, 3], [3, 4], [1, 4]]
      dfs   = DFS.new(graph.adjacency_list)

      dfs.detect_finishing_times!.must_equal [3, 2, 1, 0]
      dfs.explored.must_equal ([true] * 4)
    end
  end
end

describe '#unleash_the_power_of_kosaraju!' do
  it do
    graph = Graph.new [[1, 4],
                       [2, 8],
                       [3, 6],
                       [4, 7],
                       [5, 2],
                       [6, 9],
                       [7, 1],
                       [8, 5],
                       [8, 6],
                       [9, 7],
                       [9, 3]]

    unleash_the_power_of_kosaraju!(graph).must_equal [3, 3, 3, 0, 0]


    graph = Graph.new [[1, 2],
                       [2, 6],
                       [2, 3],
                       [2, 4],
                       [3, 1],
                       [3, 4],
                       [4, 5],
                       [5, 4],
                       [6, 5],
                       [6, 7],
                       [7, 6],
                       [7, 8],
                       [8, 5],
                       [8, 7]]

    unleash_the_power_of_kosaraju!(graph).must_equal [3, 3, 2, 0, 0]


    graph = Graph.new [[1, 2],
                       [2, 3],
                       [3, 1],
                       [3, 4],
                       [5, 4],
                       [6, 4],
                       [8, 6],
                       [6, 7],
                       [7, 8]]

    unleash_the_power_of_kosaraju!(graph).must_equal [3, 3, 1, 1, 0]


    graph = Graph.new [[1, 2],
                       [2, 3],
                       [3, 1],
                       [3, 4],
                       [5, 4],
                       [6, 4],
                       [8, 6],
                       [6, 7],
                       [7, 8],
                       [4, 3],
                       [4, 6]]

    unleash_the_power_of_kosaraju!(graph).must_equal [7, 1, 0, 0, 0]


    graph = Graph.new [[1, 2],
                       [2, 3],
                       [2, 4],
                       [2, 5],
                       [3, 6],
                       [4, 5],
                       [4, 7],
                       [5, 2],
                       [5, 6],
                       [5, 7],
                       [6, 3],
                       [6, 8],
                       [7, 8],
                       [7, 10],
                       [8, 7],
                       [9, 7],
                       [10, 9],
                       [10, 11],
                       [11, 12],
                       [12, 10]]

    unleash_the_power_of_kosaraju!(graph).must_equal [6, 3, 2, 1, 0]

    graph = Graph.new [[2, 5],
                       [5, 7],
                       [5, 9],
                       [5, 6],
                       [7, 12],
                       [9, 6],
                       [9, 3],
                       [6, 5],
                       [6, 12],
                       [6, 3],
                       [12, 7],
                       [12, 11],
                       [3, 11],
                       [3, 8],
                       [11, 3],
                       [10, 3],
                       [8, 10],
                       [8, 4],
                       [4, 1],
                       [1, 8]]

    unleash_the_power_of_kosaraju!(graph).must_equal [6, 3, 2, 1, 0]
  end
end

def calculate_scc
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  graph = Graph.new(File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    line.split(" ").map {|l| l.to_i}
  end)

  puts "\n"
  puts '-' * 50
  puts "graph loaded with #{graph.adjacency_list.size} vertices"
  puts '-' * 50
  puts "\n"
  puts '-' * 50
  puts "SCC #{unleash_the_power_of_kosaraju!(graph)}"
  puts '-' * 50
  puts "\n"
end

calculate_scc

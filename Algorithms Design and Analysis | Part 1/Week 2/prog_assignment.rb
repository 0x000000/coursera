require 'minitest/spec'
require 'minitest/autorun'

alias context describe

PICK_FIRST = lambda do |array, offset, size|
  0
end

PICK_LAST = lambda do |array, offset, size|
  size - offset - 1
end

PICK_MEDIAN_OF_THREE = lambda do |array, offset, size|
  a, b, c = offset, (offset + size - 1) / 2, size - 1
  ea, eb, ec = array[a], array[b], array[c]

  if ea > eb
    if eb > ec
      # ea > eb > ec
      b - offset
    elsif ec > ea
      # ec > ea > eb
      a - offset
    else
      # ea > ec > eb
      c - offset
    end
  else
    if ea > ec
      # eb > ea > ec
      a - offset
    elsif ec > eb
      # ec > eb > ea
      b - offset
    else
      # eb > ec > ea
      c - offset
    end
  end
end

class QuickSort
  attr_reader :input, :pick_pivot, :comparisons

  def initialize(input, pick_pivot = PICK_FIRST)
    @input = input
    @pick_pivot = pick_pivot
    @comparisons = 0
  end

  def output
    input
  end

  def partition(offset, size, pivot_position)
    pivot_position = pivot_position + offset

    pivot, terminator = if pivot_position - offset > 0
                          @input[offset], @input[pivot_position] = @input[pivot_position], @input[offset]
                          [@input[offset], offset + 1]
                        else
                          [@input[pivot_position], pivot_position + 1]
                        end

    (size - offset - 1).times do |i|
      end_of_partition = i + offset + 1

      if pivot > @input[end_of_partition]
        @input[terminator], @input[end_of_partition] = @input[end_of_partition], @input[terminator]
        terminator += 1
      end
    end

    @input[offset], @input[terminator - 1] = @input[terminator - 1], @input[offset]

    [terminator - 1, self]
  end

  def sort(offset = 0, size = @input.size)
    case size - offset
    when 0, 1
      return self
    else
      @comparisons += (size - offset - 1)

      pivot_position = pick_pivot.call(@input, offset, size)
      pivot = partition(offset, size, pivot_position)[0]

      sort(offset, pivot)
      sort(pivot + 1, size)

      return self
    end
  end
end

describe 'PICK_FIRST' do
  it { PICK_FIRST.call([1, 1, 1, 1], 100, 333333).must_equal 0 }
  it { PICK_FIRST.call([4], 0, 3).must_equal 0 }
end

describe 'PICK_LAST' do
  it { PICK_LAST.call([0, 9, 9, 9, 9], 0, 4).must_equal 3 }
  it { PICK_LAST.call([0, 9, 9, 9, 9], 0, 3).must_equal 2 }
  it { PICK_LAST.call([0, 9, 9, 9, 9], 1, 3).must_equal 1 }
end

describe 'PICK_MEDIAN_OF_THREE' do
  it { PICK_MEDIAN_OF_THREE.call([2, 1], 0, 2).must_equal 0 }

  it { PICK_MEDIAN_OF_THREE.call([1, 2, 3], 0, 3).must_equal 1 }
  it { PICK_MEDIAN_OF_THREE.call([1, 3, 2], 0, 3).must_equal 2 }
  it { PICK_MEDIAN_OF_THREE.call([2, 1, 3], 0, 3).must_equal 0 }
  it { PICK_MEDIAN_OF_THREE.call([2, 3, 1], 0, 3).must_equal 0 }
  it { PICK_MEDIAN_OF_THREE.call([3, 2, 1], 0, 3).must_equal 1 }
  it { PICK_MEDIAN_OF_THREE.call([3, 1, 2], 0, 3).must_equal 2 }

  it { PICK_MEDIAN_OF_THREE.call([4, 5, 6, 7], 0, 4).must_equal 1 }
  it { PICK_MEDIAN_OF_THREE.call([8, 2, 4, 5, 7, 1], 0, 6).must_equal 2 }
  it { PICK_MEDIAN_OF_THREE.call([8, 2, 4, 5, 7, 1], 2, 6).must_equal 0 }
  it { PICK_MEDIAN_OF_THREE.call([0, 2, 1, 3, 4], 0, 3).must_equal 2 }
  it { PICK_MEDIAN_OF_THREE.call([0, 5, 4, 9, 4], 1, 3).must_equal 0 }
end

describe '#partition' do
  context 'when size == input size' do
    context "when remaining array's size is 2" do
      it { QuickSort.new([1, 2]).partition(0, 2, 0)[0].must_equal 0 }
      it { QuickSort.new([1, 2]).partition(0, 2, 0)[1].output.must_equal [1, 2] }

      it { QuickSort.new([1, 2]).partition(0, 2, 1)[0].must_equal 1 }
      it { QuickSort.new([1, 2]).partition(0, 2, 0)[1].output.must_equal [1, 2] }

      it { QuickSort.new([2, 1]).partition(0, 2, 0)[0].must_equal 1 }
      it { QuickSort.new([2, 1]).partition(0, 2, 0)[1].output.must_equal [1, 2] }

      it { QuickSort.new([2, 1]).partition(0, 2, 1)[0].must_equal 0 }
      it { QuickSort.new([2, 1]).partition(0, 2, 1)[1].output.must_equal [1, 2] }
    end

    context 'when pivot position is 0' do
      let(:pivot_position) { 0 }

      context 'and offset is 0' do
        let(:offset) { 0 }

        it { QuickSort.new([3, 8, 2]).partition(0, 2, 0)[0].must_equal 0 }
        it { QuickSort.new([3, 8, 2]).partition(0, 2, 0)[1].output.must_equal [3, 8, 2] }

        it { QuickSort.new([3, 8, 2]).partition(offset, 3, pivot_position)[0].must_equal 1 }
        it { QuickSort.new([3, 8, 2]).partition(offset, 3, pivot_position)[1].output.must_equal [2, 3, 8] }

        it { QuickSort.new([1, 2, 0, 4]).partition(offset, 4, pivot_position)[0].must_equal 1 }
        it { QuickSort.new([1, 2, 0, 4]).partition(offset, 4, pivot_position)[1].output.must_equal [0, 1, 2, 4] }

        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(offset, 8, pivot_position)[0].must_equal 2 }
        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(offset, 8, pivot_position)[1].output.must_equal [1, 2, 3, 5, 8, 4, 7, 6] }
      end

      context 'and offset is > 0' do
        it { QuickSort.new([3, 8, 2]).partition(1, 3, pivot_position)[0].must_equal 2 }
        it { QuickSort.new([3, 8, 2]).partition(1, 3, pivot_position)[1].output.must_equal [3, 2, 8] }

        it { QuickSort.new([3, 8, 2]).partition(2, 3, pivot_position)[0].must_equal 2 }
        it { QuickSort.new([3, 8, 2]).partition(2, 3, pivot_position)[1].output.must_equal [3, 8, 2] }

        it { QuickSort.new([1, 2, 0, 4]).partition(1, 4, pivot_position)[0].must_equal 2 }
        it { QuickSort.new([1, 2, 0, 4]).partition(1, 4, pivot_position)[1].output.must_equal [1, 0, 2, 4] }

        it { QuickSort.new([1, 2, 0, 4]).partition(2, 4, pivot_position)[0].must_equal 2 }
        it { QuickSort.new([1, 2, 0, 4]).partition(2, 4, pivot_position)[1].output.must_equal [1, 2, 0, 4] }

        it { QuickSort.new([1, 2, 0, 4]).partition(3, 4, pivot_position)[0].must_equal 3 }
        it { QuickSort.new([1, 2, 0, 4]).partition(3, 4, pivot_position)[1].output.must_equal [1, 2, 0, 4] }

        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(3, 8, pivot_position)[0].must_equal 5 }
        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(3, 8, pivot_position)[1].output.must_equal [3, 8, 2, 4, 1, 5, 7, 6] }
      end
    end

    context 'when pivot position > 0' do
      context 'and offset is 0' do
        let(:offset) { 0 }

        it { QuickSort.new([3, 8, 2]).partition(offset, 3, 2)[0].must_equal 0 }
        it { QuickSort.new([3, 8, 2]).partition(offset, 3, 2)[1].output.must_equal [2, 8, 3] }

        it { QuickSort.new([1, 2, 0, 4]).partition(offset, 4, 2)[0].must_equal 0 }
        it { QuickSort.new([1, 2, 0, 4]).partition(offset, 4, 2)[1].output.must_equal [0, 2, 1, 4] }

        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(offset, 8, 3)[0].must_equal 4 }
        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(offset, 8, 3)[1].output.must_equal [4, 2, 3, 1, 5, 8, 7, 6] }
      end

      context 'and offset is > 0' do
        it { QuickSort.new([3, 8, 2]).partition(1, 3, 1)[0].must_equal 1 }
        it { QuickSort.new([3, 8, 2]).partition(1, 3, 1)[1].output.must_equal [3, 2, 8] }

        it { QuickSort.new([1, 2, 0, 4]).partition(2, 4, 1)[0].must_equal 3 }
        it { QuickSort.new([1, 2, 0, 4]).partition(2, 4, 1)[1].output.must_equal [1, 2, 0, 4] }

        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(3, 8, 2)[0].must_equal 4 }
        it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(3, 8, 2)[1].output.must_equal [3, 8, 2, 1, 4, 5, 7, 6] }
      end
    end
  end

  context 'when size < input.size' do
    it { QuickSort.new([1, 2, 0, 4]).partition(0, 3, 1)[0].must_equal 2 }
    it { QuickSort.new([1, 2, 0, 4]).partition(0, 3, 1)[1].output.must_equal [0, 1, 2, 4] }

    it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(0, 4, 2)[0].must_equal 0 }
    it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(0, 4, 2)[1].output.must_equal [2, 8, 3, 5, 1, 4, 7, 6] }

    it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(1, 3, 0)[0].must_equal 2 }
    it { QuickSort.new([3, 8, 2, 5, 1, 4, 7, 6]).partition(1, 3, 0)[1].output.must_equal [3, 2, 8, 5, 1, 4, 7, 6] }
  end
end

describe '#sort' do
  context 'using first pick strategy for pivot' do
    let(:result) { QuickSort.new(input).sort }

    context 'when input size is 0' do
      let(:input) { [] }

      it { result.output.must_equal [] }
      it { result.comparisons.must_equal 0 }
    end

    context 'when input size is 1' do
      let(:input) { [99] }

      it { result.output.must_equal [99] }
      it { result.comparisons.must_equal 0 }
    end

    context 'when input size is 2' do
      let(:input) { [2, 1] }

      it { result.output.must_equal [1, 2] }
      it { result.comparisons.must_equal 1 }
    end

    context 'when input size is 3' do
      let(:input) { [2, 1, 3] }

      it { result.output.must_equal [1, 2, 3] }
      it { result.comparisons.must_equal 2 }
    end

    context 'when input size is 4' do
      let(:input) { [2, 3, 1, 4] }

      it { result.output.must_equal [1, 2, 3, 4] }
      it { result.comparisons.must_equal 4 }
    end

    context 'when input size is 5' do
      let(:input) { [3, 4, 1, 2, 5] }

      it { result.output.must_equal [1, 2, 3, 4, 5] }
      it { result.comparisons.must_equal 6 }
    end

    context 'when input size is 9' do
      let(:input) { [5, 1, 8, 9, 3, 4, 2, 7, 6] }

      it { result.output.must_equal [1, 2, 3, 4, 5, 6, 7, 8, 9] }
      it { result.comparisons.must_equal 18 }
    end
  end

  context 'using last pick strategy' do
    let(:result) { QuickSort.new(input, PICK_LAST).sort }

    context 'when input size is 2' do
      let(:input) { [2, 1] }

      it { result.output.must_equal [1, 2] }
      it { result.comparisons.must_equal 1 }
    end

    context 'when input size is 3' do
      let(:input) { [3, 1, 2] }

      it { result.output.must_equal [1, 2, 3] }
      it { result.comparisons.must_equal 2 }
    end

    context 'when input size is 4' do
      let(:input) { [2, 3, 1, 4] }

      it { result.output.must_equal [1, 2, 3, 4] }
      it { result.comparisons.must_equal 6 }
    end

    context 'when input size is 5' do
      let(:input) { [3, 4, 1, 2, 5] }

      it { result.output.must_equal [1, 2, 3, 4, 5] }
      it { result.comparisons.must_equal 8 }
    end

    context 'when input size is 9' do
      let(:input) { [5, 1, 8, 9, 3, 4, 2, 7, 6] }

      it { result.output.must_equal [1, 2, 3, 4, 5, 6, 7, 8, 9] }
      it { result.comparisons.must_equal 18 }
    end
  end

  context 'using pick median-3 strategy' do
    let(:result) { QuickSort.new(input, PICK_MEDIAN_OF_THREE).sort }

    context 'when input size is 2' do
      let(:input) { [2, 1] }

      it { result.output.must_equal [1, 2] }
      it { result.comparisons.must_equal 1 }
    end

    context 'when input size is 3' do
      let(:input) { [3, 1, 2] }

      it { result.output.must_equal [1, 2, 3] }
      it { result.comparisons.must_equal 2 }
    end

    context 'when input size is 4' do
      let(:input) { [2, 3, 1, 4] }

      it { result.output.must_equal [1, 2, 3, 4] }
      it { result.comparisons.must_equal 4 }
    end

    context 'when input size is 5' do
      let(:input) { [3, 4, 1, 2, 5] }

      it { result.output.must_equal [1, 2, 3, 4, 5] }
      it { result.comparisons.must_equal 6 }
    end

    context 'when input size is 9' do
      let(:input) { [5, 1, 8, 9, 3, 4, 2, 7, 6] }

      it { result.output.must_equal [1, 2, 3, 4, 5, 6, 7, 8, 9] }
      it { result.comparisons.must_equal 16 }
    end
  end
end

def calculate_comparisons
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, 'Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`'
  end

  input = File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    line.to_i
  end

  puts "\n"
  puts '-' * 50
  puts "Total comparisons (pick first pivot): #{QuickSort.new(input.dup, PICK_FIRST).sort.comparisons}"
  puts "Total comparisons (pick last pivot): #{QuickSort.new(input.dup, PICK_LAST).sort.comparisons}"
  puts "Total comparisons (pick median-of-3 pivot): #{QuickSort.new(input, PICK_MEDIAN_OF_THREE).sort.comparisons}"
  puts '-' * 50
  puts "\n"
end

calculate_comparisons

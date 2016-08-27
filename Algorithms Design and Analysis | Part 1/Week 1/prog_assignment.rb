require 'minitest/spec'
require 'minitest/autorun'

def merge(left, right, inversions)
  merged_array = if left[left.size - 1] < right[0]
                   left + right
                 else
                   (left.size + right.size).times.map do
                     if left.first && right.first
                       if left.first < right.first
                         left.shift
                       else
                         inversions += left.size
                         right.shift
                       end
                     elsif left.first
                       left.shift
                     else
                       right.shift
                     end
                   end
                 end

  [
    merged_array,
    inversions
  ]
end

def sort(input, inversions = 0)
  case input.size
  when 0, 1
    [
      input,
      inversions
    ]
  else
    half = input.size / 2

    left, inversions  = sort(input[0...half], inversions)
    right, inversions = sort(input[half..-1], inversions)

    merge(left, right, inversions)
  end
end

alias context describe

describe "#merge" do
  context "when left array size is even" do
    let(:left) { [1, 3] }

    context "and right array size is even" do
      let(:right) { [2, 4] }

      it { merge(left, right, 0)[0].must_equal [1, 2, 3, 4] }
    end

    context "but right array size is odd" do
      let(:right) { [2] }

      it { merge(left, right, 0)[0].must_equal [1, 2, 3] }
    end
  end

  context "when left array size is odd" do
    let(:left) { [1] }

    context "and right array size is even" do
      let(:right) { [2, 4] }

      it { merge(left, right, 0)[0].must_equal [1, 2, 4] }
    end

    context "but right array size is odd" do
      let(:right) { [2] }

      it { merge(left, right, 0)[0].must_equal [1, 2] }
    end
  end

  context "when there are no inversions" do
    it { merge([1, 2], [3, 4], 0).must_equal [[1, 2, 3, 4], 0] }
  end

  context "when there are inversions" do
    it { merge([2], [1], 0).must_equal [[1, 2], 1] }
    it { merge([1, 3], [2, 5], 0).must_equal [[1, 2, 3, 5], 1] }
    it { merge([1, 3, 5], [2, 4, 6], 0).must_equal [[1, 2, 3, 4, 5, 6], 3] }
    it { merge([1, 4, 6], [2, 3, 5], 0).must_equal [[1, 2, 3, 4, 5, 6], 5] }
  end
end

describe "#sort" do
  context "when input size is 0" do
    it { sort([]).must_equal [[], 0] }
  end

  context "when input size is 1" do
    it { sort([9]).must_equal [[9], 0] }
  end

  context "when input size is 2" do
    it { sort([1, 2]).must_equal [[1, 2], 0] }
    it { sort([2, 1]).must_equal [[1, 2], 1] }
  end

  context "when input size is even" do
    it { sort([1, 2, 4, 3]).must_equal [[1, 2, 3, 4], 1] }
    it { sort([1, 2, 4, 6, 3, 5]).must_equal [[1, 2, 3, 4, 5, 6], 3] }
  end

  context "when input size is odd" do
    it { sort([1, 4, 3]).must_equal [[1, 3, 4], 1] }
    it { sort([1, 4, 6, 3, 5]).must_equal [[1, 3, 4, 5, 6], 3] }
  end

  context "special cases with inversions" do
    it { sort([3, 1, 5, 2, 4, 6]).must_equal [[1, 2, 3, 4, 5, 6], 4] }
    it { sort([6, 5, 4, 3, 2, 1]).must_equal [[1, 2, 3, 4, 5, 6], 6*(6-1)/2.0] }
    it { sort([8, 7, 6, 5, 4, 3, 2, 1]).must_equal [[1, 2, 3, 4, 5, 6, 7, 8], 8*(8-1)/2.0] }
  end
end

def calculate_inversions
  unless ENV['INPUT_FILE_PATH']
    raise ArgumentError, "Please run script with `INPUT_FILE_PATH=full/path/to/input/array.txt ruby name.rb`"
  end

  input = File.readlines(ENV['INPUT_FILE_PATH']).map do |line|
    line.to_i
  end

  puts "\n"
  puts "-" * 50
  puts "Total inversions: #{sort(input)[1]}"
  puts "-" * 50
  puts "\n"
end

calculate_inversions

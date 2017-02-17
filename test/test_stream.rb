require 'minitest/autorun'
require 'stream'

class TestStream < Minitest::Test

  def test_append_lazy
    stream = Stream.new do |g|
      g.append 1
      raise 'this implementation is not lazy'
    end

    assert_equal 1, stream.get
  end

  def test_each
    stream = Stream.new do |g|
      g.append 1
      g.append 2
    end

    assert_equal [1, 2], stream.each.to_a
  end

  def test_get
    stream = Stream.new do |g|
      g.append 1
      g.append 2
    end

    assert_equal 1, stream.get
    assert_equal 2, stream.get
  end

  def test_get_eos
    stream = Stream.new do |g|
      g.append 1
      g.append 2
    end

    assert_equal 1, stream.get
    assert_equal 2, stream.get

    assert_raises Stream::End do
      stream.get
    end
  end

  def test_get_values
    stream = Stream.new do |g|
      g.append 1
      g.append [2]
    end

    assert_equal [1],   stream.get_values
    assert_equal [[2]], stream.get_values
  end

  def test_peek
    stream = Stream.new do |g|
      g.append 1
    end

    assert_equal 1, stream.peek

    assert_equal 1, stream.get
  end

  def test_peek_values
    stream = Stream.new do |g|
      g.append 1
      g.append [2]
    end

    assert_equal [1], stream.peek_values

    assert_equal 1, stream.get

    assert_equal [[2]], stream.peek_values
  end

  def test_unget
    stream = Stream.new do |g|
      g.append 1
      g.append 2
    end

    stream.get
    stream.unget

    assert_equal 1, stream.get
  end

  def test_unget_eos
    stream = Stream.new do |g|
      g.append 1
    end

    stream.get
    stream.unget

    assert_equal 1, stream.get
  end

  def test_unget_twice
    stream = Stream.new do |g|
      g.append 1
      g.append 2
    end

    stream.get
    stream.unget

    assert_raises Stream::MultipleUnget do
      stream.unget
    end
  end

end


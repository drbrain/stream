require 'minitest/autorun'
require 'stream'

class TestStreamStreamable < Minitest::Test

  class G

    include Stream::Streamable

    def each
      yield 1
      yield 2
    end

  end

  def setup
    @stream = G.new
  end

  def test_get
    assert_equal 1, @stream.get
    assert_equal 2, @stream.get
  end

  def test_get_values
    assert_equal [1], @stream.get_values
  end

  def test_peek
    assert_equal 1, @stream.peek
    assert_equal 1, @stream.get
  end

  def test_peek_values
    assert_equal [1], @stream.peek_values
  end

  def test_unget
    @stream.get

    @stream.unget

    assert_equal 1, @stream.get
  end

end


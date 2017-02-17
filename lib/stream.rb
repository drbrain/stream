require 'fiber'

class Stream

  VERSION = '1.0'

  include Enumerable

  class Error < RuntimeError
  end

  class End < Error
  end

  class MultipleUnget < Error
  end

  def initialize(&generator)
    @done      = false
    @last_item = nil
    @items     = []

    @output_fiber = Fiber.new do
      loop do
        @input_fiber.resume if @items.empty?

        raise End if @done

        Fiber.yield @items.shift
      end
    end

    @input_fiber = Fiber.new do
      generator.call self

      @done = true
    end
  end

  def append item
    @items << item

    Fiber.yield
  end

  def each
    return enum_for __method__ unless block_given?

    begin
      while true do
        yield get
      end
    rescue End
    end
  end

  def get
    @last_item = @output_fiber.resume
  end

  alias next get

  def get_values
    [get]
  end

  alias next_values get_values

  def peek
    current_item = @last_item

    peek = get

    unget
    @last_item = current_item

    peek
  end

  def peek_values
    [peek]
  end

  def unget
    raise MultipleUnget unless @last_item

    @items << @last_item
    @last_item = nil
  end

end

require 'stream/streamable'


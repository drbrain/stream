require 'fiber'

##
# This stream library is like an Enumerator but allows you to push an item
# back onto the stream.

class Stream

  ##
  # The version of Stream you are using

  VERSION = '1.0'

  include Enumerable

  ##
  # Stream error base class

  class Error < RuntimeError
  end

  ##
  # Raised when you reach the end of the stream.
  #
  # Similar in purpose to StopIteration

  class End < Error
  end

  ##
  # Raised when you try to unget more than one item from the stream.

  class MultipleUnget < Error
  end

  ##
  # Creates a new Stream that uses the +generator+ block to generate new
  # items.
  #
  # The +generator+ block is given the stream as an argument.  It must
  # generate the next value in the stream and #append it to the stream.
  #
  # A stream instance is lazy, the +generator+ block will only be called when
  # a new item is needed.
  #
  # The generator must #append all items defining the stream in one call to
  # the block.  The call to #append will block until it is needed.  If the
  # stream is infinite the generator block must loop infinitely.
  #
  # Example:
  #
  #   stream = Stream.new do |g|
  #     g.append 1
  #     g.append 2
  #   end
  #
  #   stream.each do |item|
  #     puts item
  #   end

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

  ##
  # Appends +item+ to the stream.
  #
  # Call this only from the stream generator block.
  #
  # A call to #append will block until a call to #get retrieves the appended
  # item.

  def append item
    @items << item

    Fiber.yield
  end

  ##
  # Yields each item in the stream.

  def each
    return enum_for __method__ unless block_given?

    begin
      while true do
        yield get
      end
    rescue End
    end
  end

  ##
  # Retrieves one item from the stream.
  #
  # Raises Stream::End if there are no more items.
  #
  # A call to #get will block until the generator block calls #append to add
  # an item.

  def get
    @last_item = @output_fiber.resume
  end

  ##
  # Retrieves one item from the stream.
  #
  # This method is for compatibility with Enumerator#next
  #
  # See also #get_values

  alias next get

  ##
  # Retrieves one item from the stream as an Array
  #
  # This method is for compatibility with Enumerator#next_values
  #
  # Raises Stream::End if there are no more items.
  #
  # A call to #get_values will block until the generator block calls #append
  # to add an item.

  def get_values
    [get]
  end

  ##
  # Retrieves one item from the stream as an Array
  #
  # This method is for compatibility with Enumerator#next_values
  #
  # See also #get_values

  alias next_values get_values

  ##
  # Looks at the next item in the Stream but does not advance the stream
  # pointer.
  #
  # Raises Stream::End if there are no more items.
  #
  # A call to #peek will block until the generator block calls #append to add
  # an item.

  def peek
    current_item = @last_item

    peek = get

    unget
    @last_item = current_item

    peek
  end

  ##
  # Looks at the next item in the Stream but does not advance the stream
  # pointer.
  #
  # This method is for compatibility with Enumerator#peek_values
  #
  # Raises Stream::End if there are no more items.
  #
  # A call to #peek will block until the generator block calls #append to add
  # an item.

  def peek_values
    [peek]
  end

  ##
  # Returns the last item to the stream.
  #
  # You can only return one item to the stream.
  #
  # You cannot #unget after #peek or #peek_values.

  def unget
    raise MultipleUnget unless @last_item

    @items << @last_item
    @last_item = nil
  end

end

require 'stream/streamable'


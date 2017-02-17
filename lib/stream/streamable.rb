require 'forwardable'

##
# Include Stream::Streamable to add Stream behavior to any object that
# responds to #each.
#
# This behavior is similar to including Enumerable.

module Stream::Streamable

  extend Forwardable

  ##
  # Turns the results from #each into a stream.  Items from #each will be
  # returned lazily.

  def stream
    @__stream ||=
      Stream.new do |g|
        each do |item|
          g.append item
        end
      end
  end

  def_delegators :stream, :get, :get_values, :peek, :peek_values, :unget

end


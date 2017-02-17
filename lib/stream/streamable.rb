require 'forwardable'

module Stream::Streamable

  extend Forwardable

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


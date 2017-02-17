require 'fiber'

counter = 0

fiber = Fiber.new do
  loop do
    Fiber.yield counter
    counter += 1
  end
end

puts fiber.resume
puts fiber.resume
puts fiber.resume
counter = 0
puts fiber.resume


# frozen_string_literal: true
module InvaderScanner
  Match = Struct.new(:x, :y, :score, keyword_init: true) do
    def to_s = "at [x: #{x}, y: #{y}] score: #{format('%.2f', score)}"
    def to_h = { x: x, y: y, score: score.round(3) }
  end
end

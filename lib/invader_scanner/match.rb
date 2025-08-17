# frozen_string_literal: true

module InvaderScanner
  Match = Struct.new(:x, :y, :score, :truncated, :coverage, keyword_init: true) do
    def to_s
      base = "at [x: #{x}, y: #{y}] score: #{format('%.2f', score)}"
      base += " (truncated #{(coverage * 100).round}%)" if truncated
      base
    end

    def to_h = { x: x, y: y, score: score.round(3), truncated: truncated, coverage: coverage.round(3) }
  end
end

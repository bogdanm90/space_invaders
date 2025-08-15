# frozen_string_literal: true
module InvaderScanner
  class Detector
    DEFAULTS = {
      threshold:         0.8,
      max_false_pos_pct: 0.50,
      max_false_neg_pct: 0.50
    }.freeze

    def initialize(**opts)
      @threshold         = opts.fetch(:threshold, DEFAULTS[:threshold])
      @max_false_pos_pct = opts.fetch(:max_false_pos_pct, DEFAULTS[:max_false_pos_pct])
      @max_false_neg_pct = opts.fetch(:max_false_neg_pct, DEFAULTS[:max_false_neg_pct])
    end

    # Returns Array<Match>
    def matches(sample_grid, pattern)
      mh = pattern.height
      mw = pattern.width
      p_bits = pattern.grid.to_bitmask

      (0..(sample_grid.height - mh)).flat_map do |y|
        (0..(sample_grid.width - mw)).filter_map do |x|
          sub_bits = sample_grid.slice(y, x, mh, mw).to_bitmask
            evaluate_window(x, y, p_bits, sub_bits, pattern.ones)
        end
      end
    end

    private

    def evaluate_window(x, y, mask, window, mask_ones)
      hits = false_pos = false_neg = 0

      mask.each_with_index do |row, ry|
        row.each_with_index do |bit, rx|
          w = window[ry][rx]
          next if bit.zero? && w.zero?

          if bit == 1 && w == 1 then hits      += 1
          elsif bit == 0 && w == 1 then false_pos += 1
          elsif bit == 1 && w == 0 then false_neg += 1
          end
        end
      end

      score = hits.to_f / mask_ones
      return unless score >= @threshold
      return if false_pos > @max_false_pos_pct * mask_ones
      return if false_neg > @max_false_neg_pct * mask_ones

      Match.new(x: x, y: y, score: score)
    end

    protected :evaluate_window
  end
end

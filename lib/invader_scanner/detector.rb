# frozen_string_literal: true

module InvaderScanner
  class Detector
    DEFAULTS = {
      threshold: 0.8,
      max_false_pos_pct: 0.80,
      max_false_neg_pct: 0.80,
      min_coverage: 0.60
    }.freeze

    def initialize(**opts)
      @threshold         = opts.fetch(:threshold, DEFAULTS[:threshold])
      @max_false_pos_pct = opts.fetch(:max_false_pos_pct, DEFAULTS[:max_false_pos_pct])
      @max_false_neg_pct = opts.fetch(:max_false_neg_pct, DEFAULTS[:max_false_neg_pct])
      @min_coverage      = opts.fetch(:min_coverage, DEFAULTS[:min_coverage])
    end

    def matches(sample_grid, pattern)
      mh = pattern.height
      mw = pattern.width
      p_bits = pattern.grid.to_bitmask

      start_y_min = - (mh - 1)
      start_x_min = - (mw - 1)

      start_y_max = sample_grid.height - 1
      start_x_max = sample_grid.width - 1

      (start_y_min..start_y_max).flat_map do |y|
        (start_x_min..start_x_max).filter_map do |x|
          evaluate_partial_window(sample_grid, pattern, p_bits, x, y)
        end
      end
    end

    private

    def evaluate_partial_window(grid, pattern, mask, origin_x, origin_y)
      gh = grid.height
      gw = grid.width
      mh = pattern.height
      mw = pattern.width
      mask_ones_total = pattern.ones

      ov_y_start = [0, origin_y].max
      ov_y_end   = [gh - 1, origin_y + mh - 1].min
      ov_x_start = [0, origin_x].max
      ov_x_end   = [gw - 1, origin_x + mw - 1].min

      return if ov_y_start > ov_y_end || ov_x_start > ov_x_end

      hits = false_pos = false_neg = 0
      visible_mask_ones = 0

      (ov_y_start..ov_y_end).each do |gy|
        mask_row_index = gy - origin_y
        mask_row = mask[mask_row_index]
        grid_row = grid.lines[gy]
        (ov_x_start..ov_x_end).each do |gx|
          mask_col_index = gx - origin_x
          bit = mask_row[mask_col_index]
          next if bit.zero? && grid_row[gx] != 'o'

          w = grid_row[gx] == 'o' ? 1 : 0
          if bit == 1
            visible_mask_ones += 1
            w == 1 ? (hits += 1) : (false_neg += 1)
          elsif w == 1 # bit == 0
            false_pos += 1
          end
        end
      end

      return if visible_mask_ones.zero?

      score = hits.to_f / visible_mask_ones
      return if score < @threshold
      return if false_pos > @max_false_pos_pct * visible_mask_ones
      return if false_neg > @max_false_neg_pct * visible_mask_ones

      truncated = (visible_mask_ones < mask_ones_total)
      coverage = visible_mask_ones.to_f / mask_ones_total
      return if coverage < @min_coverage

      Match.new(x: origin_x, y: origin_y, score: score, truncated: truncated, coverage: coverage)
    end
  end
end

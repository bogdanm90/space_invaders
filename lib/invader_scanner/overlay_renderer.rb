# frozen_string_literal: true

require 'set'

module InvaderScanner
  # Renders radar ASCII with matched pattern cells highlighted (ANSI colors)
  # Each pattern gets its own color. Existing 'o' in that cell keeps char but is colored; '-' replaced by colored 'o' unless fill_missing=false.
  class OverlayRenderer
    RESET = "\e[0m".freeze
    PALETTE = [
      "\e[34m", # blue
      "\e[33m", # yellow
      "\e[32m", # green
      "\e[35m", # magenta
      "\e[36m", # cyan
      "\e[31m"  # red (fallback / extra)
    ].freeze

    def initialize(radar_lines, report, fill_missing: true)
      @radar_lines  = radar_lines
      @report       = report
      @fill_missing = fill_missing
    end

    def to_s
      highlights, legend = build_highlight_coords
      rendered_rows = @radar_lines.each_with_index.map do |row, y|
        chars = row.chars
        chars.each_index.map do |x|
          if (entry = highlights[[x, y]])
            color = entry[:color]
            ch = chars[x]
            out_ch = if ch.downcase == 'o'
                       ch
                     else
                       @fill_missing ? 'o' : ch
                     end
            color + out_ch + RESET
          else
            chars[x]
          end
        end.join
      end
      header(legend) + rendered_rows.join("\n")
    end

    private

    def build_highlight_coords
      map = {}
      legend = []
      @report.results.each_with_index do |(pattern, matches), idx|
        color = PALETTE[idx % PALETTE.length]
        legend << [pattern.name, color]
        mask = pattern.grid.to_bitmask
        matches.each do |m|
          mask.each_with_index do |row, dy|
            row.each_with_index do |bit, dx|
              next unless bit == 1
              map[[m.x + dx, m.y + dy]] ||= { color: color, patterns: [] }
              map[[m.x + dx, m.y + dy]][:patterns] << pattern.name
            end
          end
        end
      end
      [map, legend]
    end

    def header(legend)
      legend_str = legend.map.with_index { |(name, color), i| "#{color}#{name}#{RESET}=#{color}o#{RESET}" }.join('  ')
      <<~H
      # Overlay view (colored 'o' = pattern cell; colored replacement 'o' means inferred missing)
      # Legend: #{legend_str}

      H
    end
  end
end

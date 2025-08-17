# frozen_string_literal: true

module InvaderScanner
  class OverlayRenderer
    RESET = "\e[0m"
    PALETTE = [
      "\e[31m", # red
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
                       @fill_missing ? 'x' : ch
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
      legend_str = legend.map.with_index do |(name, color), _i|
        "#{color}#{name}#{RESET}=#{color}o#{RESET}"
      end.join('  ')
      <<~H
        # Overlay view (colored 'o' = pattern cell; colored replacement 'x' means inferred missing)
        # Legend: #{legend_str}

      H
    end
  end
end

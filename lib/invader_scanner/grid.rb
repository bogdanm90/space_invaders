# frozen_string_literal: true

module InvaderScanner
  # Immutable wrapper around lines of ASCII radar data
  class Grid
    attr_reader :height, :width, :lines

    def initialize(lines)
      raise ArgumentError, 'empty grid' if lines.nil? || lines.empty?

      @lines  = lines.map(&:dup).freeze
      @height = @lines.size
      @width  = @lines.first.size
    end

    def slice(y, x, h, w)
      Grid.new(@lines.slice(y, h).map { |row| row.slice(x, w) })
    end

    def to_bitmask
      @bitmask ||= @lines.map { |row| row.chars.map { |c| c == 'o' ? 1 : 0 } }
    end
  end
end

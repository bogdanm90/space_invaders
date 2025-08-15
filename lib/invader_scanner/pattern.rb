# frozen_string_literal: true
module InvaderScanner
  class Pattern
    attr_reader :name, :grid, :ones

    def initialize(lines, name:)
      @name  = name
      @grid  = Grid.new(lines)
      @ones  = grid.to_bitmask.sum { |r| r.sum }
    end

    def height = grid.height
    def width  = grid.width
  end
end

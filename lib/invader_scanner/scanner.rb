# frozen_string_literal: true
require "json"

module InvaderScanner
  class Report
    attr_reader :results # { pattern => [Match, ...] }

    def initialize(results) = @results = results

    def to_s
      results.map do |pattern, matches|
        <<~TXT
        Invader #{pattern.name}  (#{pattern.width}×#{pattern.height})
          ↳ detected #{matches.size} #{matches.size == 1 ? 'time' : 'times'}
             #{matches.map(&:to_s).join("\n     ")}
        TXT
      end.join("\n")
    end

    def to_json(*)
      results.transform_values { |ms| ms.map(&:to_h) }.to_json
    end
  end

  class Scanner
    KNOWN_INVADERS = [
      Pattern.new(<<~I.lines(chomp: true), name: '#1'),
--o-----o--
---o---o---
--ooooooo--
-oo-ooo-oo-
ooooooooooo
o-ooooooo-o
o-o-----o-o
---oo-oo---
I
      Pattern.new(<<~I.lines(chomp: true), name: '#2'),
---oo---
--oooo--
-oooooo-
oo-oo-oo
oooooooo
--o--o--
-o-oo-o-
o-o--o-o
I
    ].freeze

    def initialize(detector: :naive, **detector_opts)
      sym = detector.to_sym
      if sym == :naive
        @detector = Detector.new(**detector_opts)
      else
        raise ArgumentError, "Unknown detector: #{sym} (only :naive supported)"
      end
    end

    def scan(radar_sample:)
      grid    = Grid.new(radar_sample)
      results = KNOWN_INVADERS.to_h do |pattern|
        [pattern, @detector.matches(grid, pattern)]
      end
      Report.new(results)
    end
  end
end

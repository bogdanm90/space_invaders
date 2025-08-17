# Invader Scanner

CLI + Ruby library for detecting ASCII "space invaders" in radar text samples using a basic sliding-window matcher.

## Quick start

```bash
bundle install
bundle exec rake   # run specs
```

Run a scan (create `samples/radar.txt` first):

```bash
bin/scan_radar samples/radar.txt            # pretty output
bin/scan_radar samples/radar.txt --format json
bin/scan_radar samples/radar.txt --overlay   # pretty output + ANSI overlay
bin/scan_radar samples/radar.txt --overlay --no-fill-missing
```

Adjust thresholds:

```bash
bin/scan_radar samples/radar.txt --threshold 0.85 --max-fp 0.10 --max-fn 0.20
```

## Configuration

Threshold params balance precision/recall:

- --threshold : minimum ratio of matching 'o' pixels (default 0.8)
- --max-fp : max false positive pixels ratio (default 0.25)
- --max-fn : max false negative pixels ratio (default 0.25)

Overlay options:

- --overlay : after textual report prints colored ASCII overlay (matched pattern cells in red)
- --no-fill-missing : keep original '-' characters where a pattern cell was expected (default fills them with red 'o')
- --min-coverage : minimal fraction (0..1) of pattern 'o' cells that must fall inside radar to accept a (possibly truncated) match (default 0.50)

Edge / truncated detection:

The matcher now scans beyond all borders (pattern origin can be negative or extend past bottom/right). If only a part of the pattern is visible and passes thresholds and --min-coverage, the match is kept and marked as:

    (truncated XX%)  # XX = visible coverage of original pattern 'o' bits

Coordinates (x,y) can therefore be negative for top/left truncated invaders. Increase or decrease --min-coverage to tune sensitivity to edge fragments (e.g. 0.3 to allow smaller slivers, 0.8 to require large portion).

## API Sketch

```ruby
scanner = InvaderScanner::Scanner.new(threshold: 0.8)
report  = scanner.scan(radar_sample: File.readlines("samples/radar.txt", chomp: true))
puts report.to_json

# Overlay in code
overlay = InvaderScanner::OverlayRenderer.new(File.readlines("samples/radar.txt", chomp: true), report)
puts overlay.to_s

# Example with min coverage override (CLI):
# bin/scan_radar samples/radar.txt --min-coverage 0.7 --threshold 0.8 --overlay
```

Have fun hunting invaders! 👾

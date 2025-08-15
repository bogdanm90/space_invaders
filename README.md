# Invader Scanner

CLI + Ruby library for detecting ASCII "space invaders" in radar text samples using a naive sliding-window matcher.

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

## API Sketch

```ruby
scanner = InvaderScanner::Scanner.new(threshold: 0.8)
report  = scanner.scan(radar_sample: File.readlines("samples/radar.txt", chomp: true))
puts report.to_json

# Overlay in code
overlay = InvaderScanner::OverlayRenderer.new(File.readlines("samples/radar.txt", chomp: true), report)
puts overlay.to_s
```

Have fun hunting invaders! 👾

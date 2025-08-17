# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'End-to-end scan' do
  let(:radar_path) { File.join(__dir__, 'fixtures', 'radar.txt') }
  let(:radar)      { File.readlines(radar_path, chomp: true) }
  let(:scanner)    { InvaderScanner::Scanner.new(detector: :basic) }

  it 'finds at least one invader in sample' do
    report = scanner.scan(radar_sample: radar)
    total  = report.results.values.flatten.size
    expect(total).to be > 0
  end
end

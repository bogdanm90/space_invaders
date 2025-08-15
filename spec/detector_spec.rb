# frozen_string_literal: true
require "spec_helper"

RSpec.describe InvaderScanner::Detector do
  let(:pattern)  { InvaderScanner::Pattern.new(["oo","oo"], name: "mini") }
  let(:detector) { described_class.new(threshold: 0.5) }

  it "finds perfect matches" do
    sample = ["oooo",
              "oooo",
              "----"]
    grid = InvaderScanner::Grid.new(sample)
    matches = detector.matches(grid, pattern).map { |m| [m.x, m.y] }
    expect(matches).to include([0,0], [1,0], [2,0])
  end

  it "rejects too-low scores" do
    sample = ["o---",
              "----"]
    grid = InvaderScanner::Grid.new(sample)
    matches = detector.matches(grid, pattern)
    expect(matches).to be_empty
  end
end

require "rake/testtask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc "Run performance benchmarks (ENV: H, W, DENSITY, ITERS, PATTERN)"
task :bench do
	sh "bundle exec ruby bench/benchmark.rb"
end

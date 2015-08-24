require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: [:test, :rubocop]

desc "Run rubocop"
task :rubocop do
  RuboCop::RakeTask.new
end

Rake::TestTask.new do |t|
  t.libs << "test/unit"
  t.test_files = FileList["test/unit/**/*_test.rb"]
  t.verbose = false
end

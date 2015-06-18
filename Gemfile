source "https://rubygems.org"

gemspec name: "roger"

gem "rake"

gem "pry"

# Only coverage support in CI, CODECLIMATE TOKEN is part of travis.yml
gem "codeclimate-test-reporter", group: :test, require: nil if ENV["CODECLIMATE_REPO_TOKEN"]

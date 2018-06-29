$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sidekiq_stats/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sidekiq_stats"
  s.version     = SidekiqStats::VERSION
  s.authors     = ["Cristian Bica"]
  s.email       = ["cristian.bica@gmail.com"]
  s.homepage    = "https://github.com/cristianbica/sidekiq_stats"
  s.summary     = "Sidekiq statistics."
  s.description = "Sidekiq statistics."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2"
end

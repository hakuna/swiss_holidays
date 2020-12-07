$:.push File.expand_path("lib", __dir__)

require 'swiss_holidays/version'

Gem::Specification.new do |spec|
  spec.name        = "swiss_holidays"
  spec.version     = SwissHolidays::VERSION
  spec.authors     = ["Steven Schmid"]
  spec.email       = ["steven@hakuna.ch"]
  spec.homepage    = "https://www.hakuna.ch"
  spec.summary     = "Generate swiss holidays for a given canton and date range"
  spec.description = "Generate swiss holidays for a given canton and date range"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{lib,data}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rake'
end

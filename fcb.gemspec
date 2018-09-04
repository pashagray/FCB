
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fcb/version"

Gem::Specification.new do |spec|
  spec.name          = "fcb"
  spec.version       = FCB::VERSION
  spec.authors       = ["Pavel Tkachenko"]
  spec.email         = ["tpepost@gmail.com"]

  spec.summary       = %q{Wrapper for Kazakhstan First Credit Bureau API services}
  spec.description   = %q{Wrapper for Kazakhstan First Credit Bureau API services}
  spec.homepage      = "https://github.com/PavelTkachenko/FCB"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dry-monads", "~> 0.4.0"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "nori"
  spec.add_runtime_dependency "builder"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv"
end

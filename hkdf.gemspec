# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "hkdf"
  s.version     = "0.3.0"
  s.authors     = ["John Downey"]
  s.email       = ["jdowney@gmail.com"]
  s.homepage    = "http://github.com/jtdowney/hkdf"
  s.license     = "MIT"
  s.summary     = "HMAC-based Key Derivation Function"
  s.description = <<~DESC
    A ruby implementation of RFC5869: HMAC-based Extract-and-Expand Key Derivation Function (HKDF). The goal of HKDF is
    to take some source key material and generate suitable cryptographic keys from it.
  DESC

  s.files         = Dir.glob("lib/**/*") + %w[README.md LICENSE]
  s.test_files    = Dir.glob("spec/**/*")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.4"

  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "rspec", "~> 3.9"
  s.add_development_dependency "rubocop", "~> 1.12"
  s.add_development_dependency "rubocop-rake", "~> 0.5.1"
  s.add_development_dependency "rubocop-rspec", "~> 2.2"
end

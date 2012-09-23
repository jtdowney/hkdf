Gem::Specification.new do |s|
  s.name        = 'hkdf'
  s.version     = '0.2.0'
  s.authors     = ['John Downey']
  s.email       = ['jdowney@gmail.com']
  s.homepage    = 'http://github.com/jtdowney/hkdf'
  s.summary     = %q{HMAC-based Key Derivation Function}
  s.description = %q{A ruby implementation of RFC5869: HMAC-based Extract-and-Expand Key Derivation Function (HKDF). The goal of HKDF is to take some source key material and generate suitable cryptographic keys from it.}

  s.files         = Dir.glob('lib/**/*') + %w{README.md}
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'
  s.add_development_dependency 'rspec'
end

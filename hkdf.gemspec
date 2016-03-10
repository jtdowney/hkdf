Gem::Specification.new do |s|
  s.name        = 'hkdf'
  s.version     = '0.2.0'
  s.authors     = ['John Downey']
  s.email       = ['jdowney@gmail.com']
  s.homepage    = 'http://github.com/jtdowney/hkdf'
  s.license     = 'MIT'
  s.summary     = %q{HMAC-based Key Derivation Function}
  s.description = %q{A ruby implementation of RFC5869: HMAC-based Extract-and-Expand Key Derivation Function (HKDF). The goal of HKDF is to take some source key material and generate suitable cryptographic keys from it.}

  s.files         = Dir.glob('lib/**/*') + %w{README.md LICENSE}
  s.test_files    = Dir.glob('spec/**/*')
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'rake', '10.5.0'
  s.add_development_dependency 'rspec', '3.4.0'
end

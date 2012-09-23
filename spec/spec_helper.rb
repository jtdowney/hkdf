require 'hkdf'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = 'random'
end

def test_vectors
  test_lines = File.readlines('spec/test_vectors.txt').map(&:strip).reject(&:empty?)

  vectors = {}
  test_lines.each_slice(8) do |lines|
    name = lines.shift
    values = lines.inject({}) do |hash, line|
      key, value = line.split('=').map(&:strip)
      value = '' unless value
      value = [value.slice(2..-1)].pack('H*') if value.start_with?('0x')
      hash[key.to_sym] = value
      hash
    end
    vectors[name] = values
  end
  vectors
end

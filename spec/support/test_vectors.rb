# frozen_string_literal: true

# :nodoc:
module TestVectors
  module_function

  # :nodoc:
  def vectors
    test_parts = File.readlines("spec/fixtures/test_vectors.txt")
                     .map(&:strip)
                     .reject(&:empty?)
                     .each_slice(8)

    test_parts.reduce({}) do |vectors, lines|
      name = lines.shift
      values = split_test_vector(lines)
      vectors.merge(name => values)
    end
  end

  # :nodoc:
  def split_test_vector(lines)
    lines.reduce({}) do |hash, line|
      key, value = line.split("=").map(&:strip)
      value ||= ""
      value = [value.slice(2..-1)].pack("H*") if value.start_with?("0x")
      hash.merge(key.to_sym => value)
    end
  end
end

# frozen_string_literal: true

require 'openssl'
require 'stringio'

# Provide HMAC-based Extract-and-Expand Key Derivation Function (HKDF) for Ruby.
class HKDF
  # Default hash algorithm to use for HMAC.
  DEFAULT_ALGOTIHM = 'SHA256'
  # Default buffer size for reading source IO.
  DEFAULT_READ_SIZE = 512 * 1024

  # Create a new HKDF instance with then provided +source+ key material.
  #
  # Options:
  # - +algorithm:+ hash function to use (defaults to SHA-256)
  # - +info:+ optional context and application specific information
  # - +salt:+ optional salt value (a non-secret random value)
  # - +read_size:+ buffer size when reading from a source IO
  def initialize(source, options = {})
    source = StringIO.new(source) if source.is_a?(String)

    algorithm = options.fetch(:algorithm, DEFAULT_ALGOTIHM)
    @digest = OpenSSL::Digest.new(algorithm)
    @info = options.fetch(:info, '')

    salt = options[:salt]
    salt = 0.chr * @digest.digest_length if salt.nil? || salt.empty?
    read_size = options.fetch(:read_size, DEFAULT_READ_SIZE)

    @prk = generate_prk(salt, source, read_size)
    @position = 0
    @blocks = ['']
  end

  # Returns the hash algorithm this instance was configured with.
  def algorithm
    @digest.name
  end

  # Maximum length that can be derived per the RFC.
  def max_length
    @max_length ||= @digest.digest_length * 255
  end

  # Adjust the reading position to an arbitrary offset. Will raise +RangeError+ if you attempt to seek longer than
  # +#max_length+.
  def seek(position)
    raise RangeError, "cannot seek past #{max_length}" if position > max_length

    @position = position
  end

  # Adjust reading position back to the beginning.
  def rewind
    seek(0)
  end

  # Read the next +length+ bytes from the stream. Will raise +RangeError+ if you attempt to read beyond +#max_length+.
  def next_bytes(length)
    new_position = length + @position
    raise RangeError, "requested #{length} bytes, only #{max_length} available" if new_position > max_length

    generate_blocks(new_position)

    start = @position
    @position = new_position

    @blocks.join('').slice(start, length)
  end

  # Read the next +length+ bytes from the stream and return them hex encoded. Will raise +RangeError+ if you attempt to
  # read beyond +#max_length+.
  def next_hex_bytes(length)
    next_bytes(length).unpack1('H*')
  end

  # :nodoc:
  def inspect
    "#{to_s[0..-2]} algorithm=#{@digest.name.inspect} info=#{@info.inspect}>"
  end

  private

  def generate_prk(salt, source, read_size)
    hmac = OpenSSL::HMAC.new(salt, @digest)
    while (block = source.read(read_size))
      hmac.update(block)
    end
    hmac.digest
  end

  def generate_blocks(length)
    start = @blocks.size
    block_count = (length.to_f / @digest.digest_length).ceil
    start.upto(block_count) do |n|
      @blocks << OpenSSL::HMAC.digest(@digest, @prk, @blocks[n - 1] + @info + n.chr)
    end
  end
end

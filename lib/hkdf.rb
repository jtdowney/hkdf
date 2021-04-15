# frozen_string_literal: true

require 'openssl'
require 'stringio'

class HKDF
  DEFAULT_ALGOTIHM = 'SHA256'
  DEFAULT_READ_SIZE = 512 * 1024

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

  def algorithm
    @digest.name
  end

  def max_length
    @max_length ||= @digest.digest_length * 255
  end

  def seek(position)
    raise RangeError, "cannot seek past #{max_length}" if position > max_length

    @position = position
  end

  def rewind
    seek(0)
  end

  def next_bytes(length)
    new_position = length + @position
    raise RangeError, "requested #{length} bytes, only #{max_length} available" if new_position > max_length

    generate_blocks(new_position)

    start = @position
    @position = new_position

    @blocks.join('').slice(start, length)
  end

  def next_hex_bytes(length)
    next_bytes(length).unpack1('H*')
  end

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

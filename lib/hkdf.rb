require 'openssl'

class HKDF
  def initialize(source, options = {})
    options = {:algorithm => 'SHA256', :info => '', :salt => nil}.merge(options)

    @digest = OpenSSL::Digest.new(options[:algorithm])
    @info = options[:info]

    salt = options[:salt]
    salt = 0.chr * @digest.digest_length if salt.nil? #or salt.empty?

    @prk = OpenSSL::HMAC.digest(@digest, salt, source)
    @position = 0
    @blocks = []
    @blocks << ''
  end

  def algorithm
    @digest.name
  end

  def max_length
    @digest.digest_length * 255
  end

  def seek(position)
    raise RangeError.new("cannot seek past #{max_length}") if position > max_length

    @position = position
  end

  def rewind
    seek(0)
  end

  def next_bytes(length)
    new_position = length + @position
    raise RangeError.new("requested #{length} bytes, only #{max_length} available") if new_position > max_length

    _generate_blocks(new_position)

    start = @position
    @position = new_position

    @blocks.join('').slice(start, length)
  end

  def next_hex_bytes(length)
    next_bytes(length).unpack('H*').first
  end

  def _generate_blocks(length)
    start = @blocks.size
    block_count = (length.to_f / @digest.digest_length).ceil
    start.upto(block_count) do |n|
      @blocks << OpenSSL::HMAC.digest(@digest, @prk, @blocks[n - 1] + @info + n.chr)
    end
  end
end

require 'spec_helper'

describe HKDF do
  before(:each) do
    @algorithm = 'SHA256'
    @source = 'source'
    @hkdf = HKDF.new(@source, :algorithm => @algorithm)
  end

  describe 'initialize' do
    it 'accepts an IO or a string as a source' do
      output1 = HKDF.new(@source).next_bytes(32)
      output2 = HKDF.new(StringIO.new(@source)).next_bytes(32)
      output1.should == output2
    end

    it 'reads in an IO at a given read size' do
      io = StringIO.new(@source)
      io.should_receive(:read).with(1)

      HKDF.new(io, :read_size => 1)
    end

    it 'reads in the whole IO' do
      hkdf1 = HKDF.new(@source, :read_size => 1)
      hkdf2 = HKDF.new(@source)

      hkdf1.next_bytes(32).should == hkdf2.next_bytes(32)
    end

    it 'defaults the algorithm to SHA-256' do
      HKDF.new(@source).algorithm.should == 'SHA256'
    end

    it 'takes an optional digest algorithm' do
      @hkdf = HKDF.new('source', :algorithm => 'SHA1')
      @hkdf.algorithm.should == 'SHA1'
    end

    it 'defaults salt to all zeros of digest length' do
      salt = 0.chr * 32

      @hkdf_salt = HKDF.new(@source, :algorithm => @algorithm, :salt => salt)
      @hkdf_nosalt = HKDF.new(@source, :algorithm => @algorithm)
      @hkdf_salt.next_bytes(32) == @hkdf_nosalt.next_bytes(32)
    end

    it 'sets salt to all zeros if empty' do
      @hkdf_blanksalt = HKDF.new(@source, :algorithm => @algorithm, :salt => '')
      @hkdf_nosalt = HKDF.new(@source, :algorithm => @algorithm)
      @hkdf_blanksalt.next_bytes(32) == @hkdf_nosalt.next_bytes(32)
    end

    it 'defaults info to an empty string' do
      @hkdf_info = HKDF.new(@source, :algorithm => @algorithm, :info => '')
      @hkdf_noinfo = HKDF.new(@source, :algorithm => @algorithm)
      @hkdf_info.next_bytes(32) == @hkdf_noinfo.next_bytes(32)
    end
  end

  describe 'max_length' do
    it 'is 255 times the digest length' do
      @hkdf.max_length.should == 255 * 32
    end
  end

  describe 'next_bytes' do
    it 'raises an error if requested size is > max_length' do
      expect { @hkdf.next_bytes(@hkdf.max_length + 1) }.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)
      expect { @hkdf.next_bytes(@hkdf.max_length) }.to_not raise_error(RangeError)
    end

    it 'raises an error if requested size + current position is > max_length' do
      expect do
        @hkdf.next_bytes(32)
        @hkdf.next_bytes(@hkdf.max_length - 31)
      end.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)
    end

    it 'advances the stream position' do
      @hkdf.next_bytes(32).should_not == @hkdf.next_bytes(32)
    end

    test_vectors.each do |name, options|
      it "matches output from the '#{name}' test vector" do
        options[:algorithm] = options[:Hash]

        hkdf = HKDF.new(options[:IKM], options)
        hkdf.next_bytes(options[:L].to_i).should == options[:OKM]
      end
    end
  end

  describe 'next_hex_bytes' do
    it 'returns the next bytes as hex' do
      @hkdf.next_hex_bytes(20).should == 'fb496612b8cb82cd2297770f83c72b377af16d7b'
    end
  end

  describe 'seek' do
    it 'sets the position anywhere in the stream' do
      @hkdf.next_bytes(10)
      output = @hkdf.next_bytes(32)
      @hkdf.seek(10)
      @hkdf.next_bytes(32).should == output
    end

    it 'raises an error if requested to seek past end of stream' do
      expect { @hkdf.seek(@hkdf.max_length + 1) }.to raise_error(RangeError, /cannot seek past \d+/)
      expect { @hkdf.seek(@hkdf.max_length) }.to_not raise_error(RangeError)
    end
  end

  describe 'rewind' do
    it 'resets the stream position to the beginning' do
      output = @hkdf.next_bytes(32)
      @hkdf.rewind
      @hkdf.next_bytes(32).should == output
    end
  end
end

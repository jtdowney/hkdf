# frozen_string_literal: true

require "spec_helper"

describe HKDF do
  subject(:hkdf) do
    described_class.new(source)
  end

  let(:source) { "source" }

  describe "initialize" do
    it "accepts an IO or a string as a source" do
      output1 = described_class.new(source).read(32)
      output2 = described_class.new(StringIO.new(source)).read(32)
      expect(output1).to eq(output2)
    end

    it "reads in an IO at a given read size" do
      io = instance_spy(StringIO, :io, read: nil)
      described_class.new(io, read_size: 1)
      expect(io).to have_received(:read).with(1)
    end

    it "reads in the whole IO" do
      hkdf1 = described_class.new(source, read_size: 1)
      hkdf2 = described_class.new(source)

      expect(hkdf1.read(32)).to eq(hkdf2.read(32))
    end

    it "defaults the algorithm to SHA-256" do
      expect(described_class.new(source).algorithm).to eq("SHA256")
    end

    it "takes an optional digest algorithm" do
      hkdf = described_class.new("source", algorithm: "SHA1")
      expect(hkdf.algorithm).to eq("SHA1")
    end

    it "defaults salt to all zeros of digest length" do
      salt = 0.chr * 32

      hkdf_salt = described_class.new(source, salt: salt)
      hkdf_nosalt = described_class.new(source)
      expect(hkdf_salt.read(32)).to eq(hkdf_nosalt.read(32))
    end

    it "sets salt to all zeros if empty" do
      hkdf_blanksalt = described_class.new(source, salt: "")
      hkdf_nosalt = described_class.new(source)
      expect(hkdf_blanksalt.read(32)).to eq(hkdf_nosalt.read(32))
    end

    it "defaults info to an empty string" do
      hkdf_info = described_class.new(source, info: "")
      hkdf_noinfo = described_class.new(source)
      expect(hkdf_info.read(32)).to eq(hkdf_noinfo.read(32))
    end
  end

  describe "max_length" do
    it "is 255 times the digest length" do
      expect(hkdf.max_length).to eq(255 * 32)
    end
  end

  describe "read" do
    it "does not raise if reading <= max_length" do
      expect do
        hkdf.read(hkdf.max_length)
      end.not_to raise_error
    end

    it "raises an error if requested size is > max_length" do
      expect do
        hkdf.read(hkdf.max_length + 1)
      end.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)
    end

    it "raises an error if requested size + current position is > max_length" do
      expect do
        hkdf.read(32)
        hkdf.read(hkdf.max_length - 31)
      end.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)
    end

    it "advances the stream position" do
      expect(hkdf.read(32)).not_to eq(hkdf.read(32))
    end

    TestVectors.vectors.each do |name, options|
      it "matches output from the '#{name}' test vector" do
        options[:algorithm] = options[:Hash]

        hkdf = described_class.new(options[:IKM], options)
        expect(hkdf.read(options[:L].to_i)).to eq(options[:OKM])
      end
    end
  end

  describe "read_hex" do
    it "returns the next bytes as hex" do
      expect(hkdf.read_hex(20)).to eq("fb496612b8cb82cd2297770f83c72b377af16d7b")
    end
  end

  describe "seek" do
    it "sets the position anywhere in the stream" do
      hkdf.read(10)
      output = hkdf.read(32)
      hkdf.seek(10)
      expect(hkdf.read(32)).to eq(output)
    end

    it "does not raise if <= max_length" do
      expect { hkdf.seek(hkdf.max_length) }.not_to raise_error
    end

    it "raises an error if requested to seek past end of stream" do
      expect { hkdf.seek(hkdf.max_length + 1) }.to raise_error(RangeError, /cannot seek past \d+/)
    end
  end

  describe "rewind" do
    it "resets the stream position to the beginning" do
      output = hkdf.read(32)
      hkdf.rewind
      expect(hkdf.read(32)).to eq(output)
    end
  end

  describe "inspect" do
    it "returns minimal information" do
      hkdf = described_class.new("secret", info: "public")
      expect(hkdf.inspect).to match(/^#<HKDF:0x[0-9a-f]+ algorithm="SHA256" info="public">$/)
    end
  end
end

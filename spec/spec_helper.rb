# frozen_string_literal: true

require "hkdf"
require_relative "support/test_vectors"

RSpec.configure do |config|
  config.order = "random"
end

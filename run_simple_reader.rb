# frozen_string_literal: true

require_relative 'lib/simple_reader'

File.open('out_simple.txt', 'w') do |file|
  SimpleReader.new('measurements/1k-sample.txt', file).calculate
end

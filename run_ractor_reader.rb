# frozen_string_literal: true

require_relative 'lib/ractor_reader'

File.open('out_ractor.txt', 'w') do |file|
  RactorReader.new('measurements/1k-sample.txt', file).calculate
end

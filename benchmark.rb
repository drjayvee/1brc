#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require_relative 'lib/simple_reader'
require_relative 'lib/ractor_reader'

# No-op output object that responds to :<<
no_op_writer = {}
def no_op_writer.<<(_); end

file_path = ARGV[0] || 'measurements/1k-sample.txt'
puts "Benchmarking with file: #{file_path}"

# Warm up
SimpleReader.new(file_path, no_op_writer).calculate
RactorReader.new(file_path, no_op_writer).calculate

# Benchmark SimpleReader
simple_time = Benchmark.realtime do
  SimpleReader.new(file_path, no_op_writer).calculate
end

# Benchmark RactorReader
ractor_time = Benchmark.realtime do
  RactorReader.new(file_path, no_op_writer).calculate
end

puts "\nResults:"
puts "SimpleReader: #{simple_time.round(4)} seconds"
puts "RactorReader: #{ractor_time.round(4)} seconds"
puts "Ratio (Simple/Ractor): #{(simple_time / ractor_time).round(2)}x"

if ractor_time < simple_time
  puts "RactorReader is #{(simple_time / ractor_time).round(2)}x faster"
else
  puts "SimpleReader is #{(ractor_time / simple_time).round(2)}x faster"
end
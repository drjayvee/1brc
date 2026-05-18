# frozen_string_literal: true

class SimpleReader
  def initialize(file)
    @file = file
  end

  def calculate
    # read file, store values per city
    @values_per_city = Hash.new { |h, k| h[k] = [] }
    File.foreach @file do |line|
      city, value = line.chomp.split ';'
      @values_per_city[city] << value.to_f
    end

    # for each city in alphabetical order, write the min, mean and max
    @values_per_city.sort_by { |key, _| key }.each do |city, values|
      puts [
        city,
        values.min,
        values.sum / values.length,
        values.max,
      ].join ';'
    end
  end
end

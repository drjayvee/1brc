# frozen_string_literal: true

class SimpleReader
  def initialize(file, out = $stdout)
    @file = file
    @out = out
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
      @out << ([
        city,
        values.min,
        (values.sum / values.length).round(1),
        values.max,
      ].join ';')
      @out << "\n"
    end
  end
end

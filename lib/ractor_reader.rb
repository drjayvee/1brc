# frozen_string_literal: true

require 'etc'

class RactorReader
  def initialize(file, out = $stdout)
    @file = file
    @out = out
    @file_size = File.size @file
    @ractors = []
  end

  def calculate
    create_ractors
    read_file
    join_ractors
      .sort_by { |key, _| key }
      .each do |city, values|
        @out << [city, values].join(';')
        @out << "\n"
      end
  end

  private

  # Each Ractor expects to receive individual lines or +nil+.
  # Once it receives +nil+, it will calculate and return a hash:
  #    city => [count, sum, min, max]
  def create_ractors
    ractor_count.times do
      @ractors << Ractor.new do
        city_values = Hash.new { |h, k| h[k] = [] }

        loop do
          break if (line = receive).nil?

          city, value = line.split ';'
          city_values[city] << value.to_f
        end

        city_values.transform_values! do |values|
          [
            values.length,
            values.sum,
            values.min,
            values.max,
          ]
        end
      end
    end
  end

  # Chunking strategy
  #
  # The simplest way to chunk the file is to read it line by line distribute each line to the ractors.
  # Another way is to seek to (file_size / ractor_count), then find the next newline.
  # On a legacy HDD with spinning disks, this sequential reading would likely be optimal.
  #
  # However, we can safely assume SSD or NVMe storage and parallelize reading to speed it up.
  #
  # For now, let's go with the simplest solution.
  def read_file
    ractor_index = 0
    File.foreach @file do |line|
      @ractors[ractor_index].send line

      ractor_index = (ractor_index + 1) % @ractors.size
    end

    # tell ractors we're done
    @ractors.each { it.send nil }
  end

  # Join the ractors' statistics.
  # This is single-threaded, which is a bummer, of course.
  # Returns a hash:
  #    city => [min, avg, max]
  def join_ractors
    joined = {}
    @ractors.each do |ractor|
      ractor.value.each do |city, partial_stats|
        joined[city] = if (joined_stats = joined[city]).nil?
          partial_stats
        else
          [
            partial_stats[0] + joined_stats[0],
            partial_stats[1] + joined_stats[1],
            partial_stats[2] < joined_stats[2] ? partial_stats[2] : joined_stats[2],
            partial_stats[3] > joined_stats[3] ? partial_stats[3] : joined_stats[3],
          ]
        end
      end
    end

    # calculate averages & transform array shape [count, sum, min, max] => [min, avg, max]
    joined.transform_values! do |values|
      [
        values[2], # min
        (values[1] / values[0]).round(1), # avg
        values[3], # max
      ]
    end
  end

  def ractor_count
    ENV['RACTOR_COUNT'] || [
      (Etc.nprocessors * 0.6).to_i, # not all cores are performance
      8,
    ].min
  end
end

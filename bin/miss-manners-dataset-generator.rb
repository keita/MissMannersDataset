#!/usr/bin/env ruby

# Copyright (c) 2014 Keita Yamaguchi<keita.yamaguchi@gmail.com>
# Dataset Generator for miss manners solvers
#
# This program is a modern version of Miss Mannger Data Generator in OPS5
# benchmark suite.


class Generator
  def initialize(guest_size, seat_size, min_hobby, max_hobby, seed=10)
    @random = Random.new(seed)
    @guest_size = guest_size
    @seat_size = seat_size
    @min_hobby = min_hobby
    @max_hobby = max_hobby
    @male_count = 0
    @female_count = 0
  end

  def header
    "name, sex, hobby"
  end

  def each
    @guest_size.times do |i|
      name = generate_name(i)
      sex = generate_sex
      generate_hobby.each do |hobby|
        yield name, sex, hobby
      end
    end
  end

  def generate_name(i)
    i + 1
  end

  def generate_sex()
    sex = @random.rand(1) == 0 ? :m : :f
    sex = :f if sex == :m and max_male?
    sex = :m if sex == :f and max_female?
    sex == :m ? @male_count += 1 : @female_count += 1
    return sex
  end

  def max_male?
    @male_count == (@guest_size / 2)
  end

  def max_female?
    @female_count == @guest_size - (@guest_size / 2)
  end

  def generate_hobby
    num = @random.rand(2147483647.0) / 2147483647.0
    hobby_size = @min_hobby + num * (@max_hobby - @min_hobby + 1)
    return (1..@max_hobby).to_a.sample(hobby_size, random: @random)
  end
end

generator = Generator.new(ARGV[0].to_i, ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i)
puts generator.header
generator.each do |*fields|
  puts fields.join(", ")
end

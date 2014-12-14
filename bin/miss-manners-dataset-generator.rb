#!/usr/bin/env ruby

# Copyright (c) 2014 Keita Yamaguchi<keita.yamaguchi@gmail.com>
# Dataset Generator for miss manners solvers
#
# This program is a modern version of Miss Mannger Data Generator in OPS5
# benchmark suite.

require 'erb'
require 'optparse'

class Generator
  attr_accessor :guest_size
  attr_accessor :min_hobby
  attr_accessor :max_hobby

  def initialize(seed=10)
    @random = Random.new(seed)
    @male_count = 0
    @female_count = 0
  end

  def validate
    unless not(@guest_size.nil?) && (@guest_size > 0)
      raise RuntimeError.new("guest size is invalid.")
    end

    unless not(@min_hobby.nil?) and (@min_hobby > 0)
      raise RuntimeError.new("min size is invalid.")
    end

    unless not(@max_hobby.nil?) and @max_hobby > 0
      raise RuntimeError.new("max size is invalid.")
    end

    unless @max_hobby >= @min_hobby
      raise RuntimeError.new("max size should be greater than min size.")
    end

    return true
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
    sex = @random.rand(2) == 0 ? :m : :f
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

class Printer
  attr_accessor :template

  def initialize(generator)
    @generator = generator
    @template = CSV_TEMPLATE
  end

  def print(out=STDOUT)
    erb = ERB.new(@template, nil, "%-")
    out.print(erb.result(Context.new(@generator).binding))
  end

  class Context
    attr_reader :generator
    attr_reader :name
    attr_reader :sex
    attr_reader :hobby

    def initialize(generator)
      @generator = generator
    end

    def binding
      Kernel.binding
    end
  end
end

CSV_TEMPLATE = <<__TEMPLATE__
name,sex,hobby
<%- generator.each do |*fields| -%>
<%= fields.join(",") %>
<%- end -%>
__TEMPLATE__

CLIPS_TEMPLATE = <<__TEMPLATE__
<%- generator.each do |name, sex, hobby| -%>
(make guest ^name <%= name %> ^sex <%= sex %> ^hobby <%= hobby %>)
<%- end -%>
__TEMPLATE__

if __FILE__ == $0
  $generator = Generator.new
  $printer = Printer.new($generator)

  opt = OptionParser.new
  opt.on('--type NAME') {|name|
    case name.downcase
    when "csv"
      $printer.template = CSV_TEMPLATE
    when "clips"
      $printer.template = CLIPS_TEMPLATE
    end
  }
  opt.parse!

  if ARGV.size == 3
    $generator.guest_size = ARGV[0].to_i
    $generator.min_hobby = ARGV[1].to_i
    $generator.max_hobby = ARGV[2].to_i
  else
    raise RuntimeError.new("Requires guest number, min hobby number, and max hobby number.")
  end

  if $generator.validate
    $printer.print
  end
end

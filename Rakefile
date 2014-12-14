require 'pathname'
load 'bin/miss-manners-dataset-generator.rb'

TYPES = [
  [File.join("data", "csv"), "csv", CSV_TEMPLATE],
  [File.join("data", "clips"), "clp", CLIPS_TEMPLATE],
]

HOBBIES = [
  [2, 3], [3, 5], [5, 10],
  [20, 30], [30, 50], [50, 100],
]

GUESTS = [8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]

desc "Generate dataset"
task "generate" do
  TYPES.each do |dir, ext, template|
    mkpath(dir) unless File.exist?(dir)

    HOBBIES.each do |min, max|
      GUESTS.each do |guest_size|
        filename = File.join(dir, "manners-%s-%s-%s.%s" % [guest_size, min, max, ext])
        generator = Generator.new
        generator.guest_size = guest_size
        generator.min_hobby = min
        generator.max_hobby = max
        File.open(filename, "w+") do |out|
          printer = Printer.new(generator)
          printer.template = template
          printer.print(out)
        end
      end
    end
  end
end


